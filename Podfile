# Uncomment the next line to define a global platform for your project
IOS_DEPLOYMENT_TARGET = '14.0'.freeze

platform :ios, IOS_DEPLOYMENT_TARGET

target 'RxResearch' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for RxResearch

  # Rx Core
  pod 'RxSwift'
  pod 'RxCocoa'


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
end
