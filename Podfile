platform :ios, '13.0'
use_frameworks!

target 'NoGaDa' do
  # Pods for NoGaDa
  # Rx
  pod 'RxSwift',            '~> 6.5.0'
  pod 'RxCocoa',            '~> 6.5.0'
  pod 'RxGesture',          '~> 4.0.4'
  
  # UI
  pod 'Hero',               '~> 1.6.2'
  pod 'FloatingPanel',      '~> 2.6.0'
  pod 'SafeAreaBrush',      '~> 1.0.4'
  pod 'BISegmentedControl', '~> 0.1.1'
  pod 'SwiftRater',         '~> 2.1.0'
  
  # Database
  pod 'RealmSwift'
  
  # AdMob
  pod 'Google-Mobile-Ads-SDK'
  
  # Conventions
  pod 'R.swift',            '~> 7.2.4'
  
  target 'NoGaDaTests' do
    inherit! :search_paths
    # Pods for testing
  end
  
  target 'NoGaDaUITests' do
    # Pods for testing
  end
  
end

# Limit minimum deployment target version
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
