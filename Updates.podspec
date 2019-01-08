Pod::Spec.new do |s|
  s.name             = 'Updates'
  s.version          = '0.1.0'
  s.swift_version    = '4.2'
  s.summary          = 'Notifies of updates to an iOS app.'
  s.description      = <<-DESC
Notifies of updates to an iOS app so that users may be informed and / or prompted to update.
                       DESC

  s.homepage         = 'https://github.com/rwbutler/Updates'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ross Butler' => 'github@rwbutler.com' }
  s.source           = { :git => 'https://github.com/rwbutler/Updates.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'Updates/Classes/**/*'
  
  # s.resource_bundles = {
  #   'Updates' => ['Updates/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
