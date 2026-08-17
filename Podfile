# Uncomment the next line to define a global platform for your project
IOS_DEPLOYMENT_TARGET = '14.0'.freeze

platform :ios, IOS_DEPLOYMENT_TARGET

target 'RxResearch' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for RxResearch

  # Rx Core https://github.com/ReactiveX/RxSwift
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxSwiftExt'
  pod 'NSObject+Rx'
  # 添加手势与调用会更加简单
  # RxGesture 是 RxSwiftCommunity 的库，把系统 UIGestureRecognizer（点击、长按、拖拽、捏合、滑动）封装成响应式 Observable 流，专门给 RxSwift/RxCocoa 项目用，解决原生手势写大量 delegate/selector 命令式代码的痛点
  pod 'RxGesture'
  pod 'Moya/RxSwift'
  
  # Image
  pod 'Kingfisher'
  
  # 考虑使用货拉拉的TheRouter
  pod 'TheRouter'
  
  # Auto Layout
  pod 'SnapKit'
  
  # UI
  pod 'MJRefresh'
  pod 'SVProgressHUD'
  # Keyboard,弹不出来的原因是8.0.0之后拆分为不同的模块,需要分别进行配置
  pod 'IQKeyboardManagerSwift'
  
  
  
  
  
  
  # R函数
  # 不使用pod方式,使用Swift Package方式引入 https://github.com/mac-cain13/R.swift
  # 使用步骤: TARGETS -> Build Phases -> Run Build Tool Plug‑ins -> RswiftGenerateInternalResources(Rswift)
  # 左侧目录最顶部蓝色图标右键找到 RswiftModeifyXcodePackages -> run即可
  # pod 'R.swift'
  
  # 日志打印与跟踪
  pod 'CocoaLumberjack/Swift'
  
  # 用于日志压缩为zip
  pod 'SSZipArchive'
  
  # 微软 Bug&Crash
  pod 'KSCrash'
  
  # 调试
  pod 'LookinServer', :configurations => ['Debug']
  pod 'CocoaDebug', :configurations => ['Debug']
  pod 'FunnyButton', :configurations => ['Debug']
  pod 'LifetimeTracker', :configurations => ['Debug']

end

post_install do |installer|
  # 1) Keep every pod compatible with the app's deployment target.
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']
        begin
          current = Gem::Version.new(config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'])
          if current < Gem::Version.new(IOS_DEPLOYMENT_TARGET)
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = IOS_DEPLOYMENT_TARGET
          end
        rescue
          # If parsing fails, fall back to the app deployment target.
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = IOS_DEPLOYMENT_TARGET
        end
      else
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = IOS_DEPLOYMENT_TARGET
      end

      # 2) Disable Bitcode for pod targets to avoid bitcode-related override issues
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end

  # 3) Prevent "Target overrides the 'ENABLE_BITCODE' build setting" warnings by making
  # app/user project targets use $(inherited) for ENABLE_BITCODE (so CocoaPods xcconfigs are authoritative)
  installer.aggregate_targets.each do |aggregate|
    project = aggregate.user_project
    project.targets.each do |user_target|
      user_target.build_configurations.each do |config|
        config.build_settings['ENABLE_BITCODE'] = '$(inherited)'
      end
    end
  end
  
  # 通过打印RxSwift.Resources.total表示当前的RxSwift中资源使用情况
  # https://juejin.cn/post/7088692280852217887
  # https://www.jianshu.com/p/671a68870bdf
  # Preserve existing behavior for RxSwift tracing flag
  installer.pods_project.targets.each do |target|
    if target.name == 'RxSwift'
      target.build_configurations.each do |config|
        if config.name == 'Debug'
          flags = config.build_settings['OTHER_SWIFT_FLAGS'] || ['$(inherited)']
          flags = flags.split if flags.is_a?(String)
          flags << '-D' unless flags.include?('-D')
          flags << 'TRACE_RESOURCES' unless flags.include?('TRACE_RESOURCES')
          config.build_settings['OTHER_SWIFT_FLAGS'] = flags
        end
      end
    end
  end

  # CocoaPods Keys 2.3.1 generates an NSString-backed lookup table. If a key
  # contains multi-byte UTF-8 data, characterAtIndex: counts Unicode characters
  # while the generated indexes are byte offsets, which can crash at runtime.
  # Convert the generated table to raw bytes so its indexes remain stable.
  keys_source = File.join(__dir__, 'Pods', 'CocoaPodsKeys', 'RxResearchKeys.m')
  if File.exist?(keys_source)
    source = File.binread(keys_source)
    data_declaration = /static NSString \*RxResearchKeysData = @"(.*)";/n

    if (match = source.match(data_declaration))
      data_bytes = match[1].bytes
      # The generator appends an escaped quote sentinel (\\\") to its table.
      # In the Objective-C source it is emitted as three backslashes and a quote,
      # while generated indexes address the quote directly.
      data_bytes[-4, 4] = [0x22] if data_bytes.last(4) == [0x5C, 0x5C, 0x5C, 0x22]
      byte_values = data_bytes.map { |byte| format('0x%02X', byte) }
      byte_values << '0x00'
      byte_declaration = "static const unsigned char RxResearchKeysData[] = { #{byte_values.join(', ')} };"

      source.gsub!(/\[RxResearchKeysData characterAtIndex:(\d+)\]/n, 'RxResearchKeysData[\1]')
      source.sub!(data_declaration, byte_declaration)
      File.binwrite(keys_source, source)
    end
  end
end

# 秘钥操作
# pod keys set xxx ""
# 移除其中某一个key需要时有: pod keys rm xxx
plugin 'cocoapods-keys', {
  :project => "RxResearch",
  :keys => [
    "Aliapy_Key",
    "Wechat_Key",
    "GeTuiAppSecret_Key"
  ]
}
