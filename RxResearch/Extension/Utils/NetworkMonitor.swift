//
//  NetworkMonitor.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/10.
//

import Foundation
import Network      // 系统网络框架，提供NWPathMonitor、NWInterface
import Combine      // 苹果响应式
import RxSwift      // Rx响应式
import RxRelay      // BehaviorRelay

//String：序列化可以转字符串；Codable：可以直接 JSON 编码，方便存入崩溃日志上报；Equatable：支持判等。
@available(iOS 13.0, *)
public enum NetworkInterfaceType: String, Codable, Equatable {
    case wifi
    case cellular       // 蜂窝流量 4G/5G
    case wiredEthernet  // 有线网（iPad外接网卡）
    case loopback       // 本地回环 127.0.0.1
    case other          // VPN、其他
    case unknown        // 未知
    
    //自定义构造器：把系统NWInterface.InterfaceType转为自己业务枚举。
    init(from nw: NWInterface.InterfaceType?) {
        guard let t = nw else { self = .unknown; return }
        switch t {
        case .wifi: self = .wifi
        case .cellular: self = .cellular
        case .wiredEthernet: self = .wiredEthernet
        case .loopback: self = .loopback
        default: self = .other
        }
    }
}

//NetworkStatus 网络状态 Model
@available(iOS 13.0, *)
public struct NetworkStatus: Equatable {
    public let isConnected: Bool          // 链路是否可用
    public let interface: NetworkInterfaceType // 当前网络类型
    public let rawStatus: NWPath.Status   // 系统原始状态枚举
    
    public init(isConnected: Bool, interface: NetworkInterfaceType, rawStatus: NWPath.Status = .requiresConnection) {
        self.isConnected = isConnected
        self.interface = interface
        self.rawStatus = rawStatus
    }
}

/// NetworkMonitor 通过 Combine、RxSwift 和 Swift 并发机制暴露当前网络状态。
/// - Features:
///   - `statusPublisher` (Combine) publishes `NetworkStatus`
///   - `statusObservable` (RxSwift) is an Observable stream of `NetworkStatus`
///   - `isConnectedPublisher` / `isConnectedObservable` convenience streams for Bool
@available(iOS 13.0, *)
public final class NetworkMonitor {
    //全局单例，项目全局共用同一个网络监听实例。
    public static let shared = NetworkMonitor()
    
    //Combine 输出完整网络状态；private(set)：外部只能读，不能写。Never代表不会输出 error。
    public private(set) var statusPublisher: AnyPublisher<NetworkStatus, Never>
    
    //Combine 简化流，只输出 Bool 是否连通。
    public private(set) var isConnectedPublisher: AnyPublisher<Bool, Never>
    
    //RxSwift：对外只读 Observable，底层由BehaviorRelay驱动。
    public var statusObservable: Observable<NetworkStatus> { statusRelay.asObservable() }
    
    //Rx 简化流，只输出布尔；distinctUntilChanged()：相同值不会重复下发事件，减少回调刷屏。
    public var isConnectedObservable: Observable<Bool> {
        statusRelay
            .map { $0.isConnected }
            .distinctUntilChanged()
    }
    
    //同步读取当前网络快照，不用订阅流，直接取值。底层读 Combine 的CurrentValueSubject缓存值
    public var currentStatus: NetworkStatus {
        statusSubject.value
    }
    
    //【bug 点】原本设计是兼容老代码的单个回调，但是下面addListener错误复用这个变量，多监听会互相覆盖。
    private var callback: ((NetworkStatus) -> Void)?
    
    //listeners字典：保存多个外部传入回调；key 为 UUID 唯一标识；
    private var listeners: [UUID: (NetworkStatus) -> Void] = [:]
    
    //listenersQueue：并发队列，用来线程安全读写 listeners 字典；
    private let listenersQueue = DispatchQueue(label: "com.rxstudy.network.monitor.listeners", attributes: .concurrent)
    
    //ListenerToken：资源管理令牌
    //外部拿到 token，可以手动调用cancel()移除监听；
    //deinit自动 cancel：token 被释放时自动注销监听，防止内存泄漏。
    public final class ListenerToken {
        private let cancelBlock: () -> Void
        private var cancelled = false
        public init(cancel: @escaping () -> Void) { self.cancelBlock = cancel }
        public func cancel() {
            guard !cancelled else { return }
            cancelled = true
            cancelBlock()
        }
        deinit { cancel() }
    }
    
    //返回值不用也不出现警告
    @discardableResult
    public func addListener(_ listener: @escaping (NetworkStatus) -> Void) -> ListenerToken {
        //生成 UUID 作为这个 listener 唯一 id；
        let id = UUID()
        
        //读写字典必须用 barrier，防止多线程同时读写数组 crash。
        listenersQueue.async(flags: .barrier) {
            self.listeners[id] = listener
        }
        
        //主线程中赋值
        DispatchQueue.main.async {
            //self.callback = listener
            //bug: 现在代码多次 addListener，只有最后添加的 listener 会收到立即回调。需要把self.callback = listener 改成 listener(self.currentStatus)
            listener(self.currentStatus)
        }
        
        //返回 token，token 取消时调用removeListener删除字典里的回调
        return ListenerToken { [weak self] in
            self?.removeListener(id)
        }
    }
    
    private func removeListener(_ id: UUID) {
        listenersQueue.async(flags: .barrier) {
            self.listeners.removeValue(forKey: id)
        }
    }
    
    // MARK: - Private
    private let monitor: NWPathMonitor //系统网络监听实例；
    private let monitorQueue: DispatchQueue //系统回调的后台队列；
    
    //Combine 的 CurrentValueSubject，保存最新状态，对外发送 Publisher；
    private let statusSubject: CurrentValueSubject<NetworkStatus, Never>
    //RxSwift BehaviorRelay，保存最新状态；
    private let statusRelay: BehaviorRelay<NetworkStatus>
    //Combine 生命周期管理。
    private let cancellables = Set<AnyCancellable>()
    
    //构造器支持传入requiredInterfaceType，可以只监听某一类网络（例如只监听 wifi）；不传则监听全部网络。
    public init(requiredInterface: NWInterface.InterfaceType? = nil) {
        if let requiredInterface {
            monitor = NWPathMonitor(requiredInterfaceType: requiredInterface)
        } else {
            monitor = NWPathMonitor()
        }
        monitorQueue = DispatchQueue(label: "com.rxstudy.network.monitor")//默认串行队列（Serial）
        
        //初始化默认状态：未连接，未知类型。Subject 和 Relay 初始化赋值初始值。
        let initial = NetworkStatus(isConnected: false, interface: .unknown, rawStatus: .requiresConnection)
        statusSubject = CurrentValueSubject(initial)
        statusRelay = BehaviorRelay(value: initial)
        
        //把 subject 包装对外 Publisher；removeDuplicates()：相同网络状态不重复下发；初始化直接调用start()开启监听。
        statusPublisher = statusSubject.eraseToAnyPublisher()
        isConnectedPublisher = statusPublisher
            .map { $0.isConnected }
            .removeDuplicates()
            .eraseToAnyPublisher()
        
        start()
    }
    
    //实例销毁时停止 NWPathMonitor，防止后台继续回调内存泄漏。
    deinit {
        stop()
    }
    
    public func start() {
        //pathUpdateHandler：系统网络发生变化的回调，运行在 monitorQueue 后台线程。
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            let isConnected = (path.status == .satisfied)//链路可用；
            let ifType = NetworkInterfaceType(from: path.availableInterfaces.first?.type)//取当前生效网络接口类型；
            let newStatus = NetworkStatus(isConnected: isConnected, interface: ifType, rawStatus: path.status)
            
            
            //系统回调是后台队列，UI 要切主线程。
            DispatchQueue.main.async {
                //给 Combine subject 发送新状态；
                self.statusSubject.send(newStatus)
                
                // 给 Rx Relay accept 新状态；
                self.statusRelay.accept(newStatus)
                
                //调用旧版单 callback；
                self.callback?(newStatus)
                
                //listenersQueue.sync同步读取 listeners 字典快照，遍历执行所有外部 listener 回调。
                let listenersSnapshot = self.listenersQueue.sync { Array(self.listeners.values) }
                for l in listenersSnapshot {
                    l(newStatus)
                }
            }
        }
        
        //启动 NWPathMonitor，把回调派发至monitorQueue后台队列。
        monitor.start(queue: monitorQueue)
        
        if let currentPath = monitor.currentPathIfAvailable() {
            let isConnected = (currentPath.status == .satisfied)
            let ifType = NetworkInterfaceType(from: currentPath.availableInterfaces.first?.type)
            let seed = NetworkStatus(isConnected: isConnected, interface: ifType, rawStatus: currentPath.status)
            statusSubject.send(seed)
            statusRelay.accept(seed)
            callback?(seed)
        }
    }
    
    public func stop() {
        //停止 NWPathMonitor，不再接收网络变化回调。
        monitor.cancel()
    }
}

//私有扩展访问未公开currentPath属性。苹果没有对外暴露这个 API。
private extension NWPathMonitor {
    func currentPathIfAvailable() -> NWPath? {
        return currentPath
    }
}

// MARK: - Usage example
/*
import Combine
import RxSwift

@available(iOS 13.0, *)
func example() {
    let monitor = NetworkMonitor.shared

    // Combine
    let cancellable = monitor.statusPublisher.sink { status in
        print("Combine: isConnected=\(status.isConnected), interface=\(status.interface)")
    }

    // RxSwift
    let disposable = monitor.statusObservable.subscribe(onNext: { status in
        print("Rx: isConnected=\(status.isConnected), interface=\(status.interface)")
    })

    // remember to cancel/dispose when done
    _ = (cancellable, disposable)
}
*/
