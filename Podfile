# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

target 'Mpl.' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!

  # Pods for Mpl.
  pod 'MarqueeLabel/Swift'
  pod 'NotificationBannerSwift'
  pod 'Mapbox-iOS-SDK', '~> 3.7'
  pod 'SQLite.swift', '~> 0.11.4'
  pod 'Alamofire', '~> 4.6'
  pod 'SWXMLHash', '~> 4.0.0'
  pod 'SwiftyJSON'
  pod 'Firebase/Core'
  pod 'Firebase/Performance'
  pod 'Fabric', '~> 1.7.7'
  pod 'Crashlytics', '~> 3.10.2'

end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings.delete('CODE_SIGNING_ALLOWED')
    config.build_settings.delete('CODE_SIGNING_REQUIRED')
  end
end
