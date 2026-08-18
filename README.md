## 需要记住的 Rx 基础规则


# Observable
表示一条随时间发送事件的数据流：
next → next → next → completed
也可能：next → error

一旦发出 error 或 completed，流就结束。

# PublishSubject

let subject = PublishSubject<Int>()

特点：
既可以接收事件，也可以被订阅。
不保存旧值。
订阅之前的事件收不到。

适合一次性事件：点击 重试 跳转 提示


# BehaviorRelay

let relay = BehaviorRelay(value: [])

特点：
保存当前值。
新订阅立即收到当前值。
用 accept() 更新。
不会 error 或 completed。

适合持续状态：列表数据 登录状态 loading 状态 当前页码相关状态

# Single
成功一次 或者 失败一次
非常适合网络请求 Single<Response>

# map
一对一转换，不改变事件数

# compactMap
转换并过滤 nil
规则：
有值 → 向下发送
nil  → 丢弃

# bind(onNext:)
收到事件后调用普通方法或闭包：.bind(onNext: viewModel.inputs.loadData)

# bind(to:)
把事件交给另一个 Observer
要求上下游元素类型兼容

# drive
专门用于 Driver 
.drive(tableView.rx.items)
通常用于 UI，因为 Driver 保证主线程和无 error

# subscribe
真正启动并处理一条流
冷序列——例如网络请求——通常在订阅之后才开始执行

# disposed(by:)
意思是把订阅放进释放袋。
当控制器或 ViewModel 销毁时，DisposeBag 销毁，里面的订阅统一取消。


## 首页逻辑
HomeViewController.viewDidLoad
→ BaseViewController 配置错误图
→ BaseTableViewController 配置 tableView、刷新、空数据页
→ HomeViewController 建立所有 Rx 绑定
→ loadData(.refresh)
→ Single.zip 发出三个请求
→ 请求成功
→ dataSource.accept(...)
→ tableView.rx.items
→ 创建 InfoCell
→ cell.info = info
→ 页面显示

## 下拉刷新
用户下拉
→ MJRefresh state = refreshing
→ rx.refresh 发出 Void
→ map 成 .refresh
→ loadData(.refresh)
→ 重置 pageNum 和 noMoreData
→ 请求成功
→ dataSource 替换为最新数组
→ 停止刷新动画

## 上拉加载
用户上拉
→ footer.rx.refresh
→ map 成 .loadMore
→ pageNum += 1
→ 请求下一页
→ 新数组 = 旧数组 + 下一页数组
→ 停止 footer 动画

## 网络失败且没有数据
请求失败
→ dataSource.isEmpty == true
→ networkError.onNext(moyaError)
→ HomeViewController 收到错误
→ rx.networkError Binder
→ showErrorImage()


