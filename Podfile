source 'https://github.com/grigorye/podspecs.git'
source 'https://github.com/CocoaPods/Specs.git'

install! 'cocoapods'
use_frameworks!

project 'MultifonRedirect/MultifonRedirect.xcodeproj'

target "MultifonRedirect" do
  platform :ios, '11.0'

  pod 'MultifonRedirect', :path => 'MultifonRedirect'
  pod 'GEFoundation'

  pod 'PhoneNumberKit', :path => 'GitSubtrees/PhoneNumberKit'
  pod 'Then'
	pod 'Fabric'
	pod 'Answers'
end

target 'MultifonRedirectSupport' do
  platform :ios, '11.0'

  pod 'GEFoundation'
  pod 'Then'
  pod 'PhoneNumberKit', :path => 'GitSubtrees/PhoneNumberKit'
end

target 'MultifonRedirectToday' do
  platform :ios, '11.0'

  pod 'GEFoundation'
  pod 'Then'
  pod 'PhoneNumberKit', :path => 'GitSubtrees/PhoneNumberKit'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |configuration|
      configuration.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
      configuration.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = '465NA5BW7E/'
      configuration.build_settings['ENABLE_BITCODE'] = 'NO'
      configuration.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'YES'
    end
  end
end
