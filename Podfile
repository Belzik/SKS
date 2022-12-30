platform :ios, '13.0'

inhibit_all_warnings!

target 'SKS' do
  use_frameworks!
  
  # Networking
  pod 'Alamofire', '= 5.4.2'

  # Utilities
  pod 'IQKeyboardManagerSwift', '= 6.5.6'
  pod 'ReachabilitySwift', '= 5.0.0'
  pod 'SkyFloatingLabelTextField', '= 4.0.0'
  pod 'Kingfisher', '= 6.2.1'
  pod 'EAN13BarcodeGenerator', '= 0.2.0'
  pod 'Cosmos', '= 23.0.0'
  pod 'Pulley', '= 2.9.0'
  pod 'XLPagerTabStrip', '= 9.0.0'
  pod 'FSPagerView', '= 0.8.3'
  pod 'SnapKit', '= 5.0.1'
  
  # Firebase
  pod 'Firebase/Core', '= 7.10.0'
  pod 'Firebase/Messaging', '= 7.10.0'
  
  pod 'Fabric', '= 1.10.2'
  pod 'Crashlytics', '= 3.14.0'
  # for Google Analytics
  pod 'Firebase/Analytics', '= 7.10.0'
  
  # Map
  pod 'YandexMapsMobile', '4.1.0-lite'
  
  # VK
  pod 'SwiftyVK', '= 3.4.2'

  target 'SKSTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'SKSUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
