Pod::Spec.new do |s|
  s.name             = 'Updates'
  s.version          = '1.3.0'
  s.swift_version    = '5.0'
  s.summary          = 'Updates is a framework for automatically detecting app updates and seamlessly prompting users to update.'
  s.description      = <<-DESC
Updates is a framework which automatically checks to see whether a new version of your app is available. When an update is released, Updates is able to present the new version number and accompanying release notes to the user giving them the choice to update. The update itself can then be initiated from within the app so that updating becomes effortless.
                       DESC
  s.homepage         = 'https://github.com/rwbutler/Updates'
  s.screenshots      = 'https://github.com/rwbutler/Updates/raw/master/docs/images/updates-large-logo.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ross Butler' => 'github@rwbutler.com' }
  s.source           = { :git => 'https://github.com/rwbutler/Updates.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/ross_w_butler'
  s.frameworks       = 'StoreKit'
  s.ios.deployment_target = '9.0'
  s.source_files = 'Updates/Classes/**/*'
end
