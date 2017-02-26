install! 'cocoapods', :integrate_targets => false
use_frameworks!

target "iOS" do
	platform :ios, '8.0'
	pod 'Crashlytics'
	pod 'Fabric'
	pod 'PhoneNumberKit', '~> 1.2'
end
target "macOS" do
	platform :osx, '10.11'
	pod 'Crashlytics'
	pod 'Fabric'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |configuration|
      configuration.build_settings['CONFIGURATION_BUILD_DIR'] = '${PODS_CONFIGURATION_BUILD_DIR}'
      configuration.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
      configuration.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = '465NA5BW7E/'
      configuration.build_settings['SWIFT_VERSION'] = '3.0'
      configuration.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf-with-dsym'
      configuration.build_settings['ENABLE_BITCODE'] = 'NO'
      configuration.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'NO'
      xcconfig_path = configuration.base_configuration_reference.real_path
      xcconfig = Xcodeproj::Config.new(xcconfig_path).to_hash
      
      #
      # Remove framework search paths not existing when building (dynamic) frameworks
      #
      frameworkSearchPaths = xcconfig['FRAMEWORK_SEARCH_PATHS']
      if frameworkSearchPaths != nil
        frameworkSearchPaths = frameworkSearchPaths.gsub(/"\$PODS_CONFIGURATION_BUILD_DIR\/[.a-zA-Z0-9_-]+"( |$)/, '')
        xcconfig['FRAMEWORK_SEARCH_PATHS'] = frameworkSearchPaths
      end
      
      File.open(xcconfig_path, "w") { |file|
        xcconfig.each do |key,value|
          file.puts "#{key} = #{value}"
        end
      }
    end
  end
end
