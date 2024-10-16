# Uncomment the next line to define a global platform for your project
# platform :ios, '15.0'

post_install do |installer|
 installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "15.0"
#          config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
          config.build_settings['ENABLE_BITCODE'] = 'NO'
          config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
          config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
          config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
          
          xcconfig_path = config.base_configuration_reference.real_path
          xcconfig = File.read(xcconfig_path)
          xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
          File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
    end
  end
end


target 'VPNBrowser' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for VPNBrowser 
 

  pod 'AWSMobileClient', '~> 2.15.1'
  pod 'AWSS3', '~> 2.15.1'
  pod 'SwiftJWT'

end

