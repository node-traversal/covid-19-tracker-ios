platform :ios, '13.0'
use_frameworks!
workspace 'CoronaTex.xcworkspace'
#ignore warnings from pods
inhibit_all_warnings!

target 'CoronaTex' do
  pod 'ActionSheetPicker-3.0'
  pod 'SwiftLint'
  pod 'ChartLegends'
  pod 'SwiftCharts', '~> 0.6.5'
  pod 'Alamofire'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
      config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
      config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
     end
  end
end
