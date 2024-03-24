#
# Be sure to run `pod lib lint cocoa-whisper.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'cocoa-whisper'
  s.version          = '0.1.0'
  s.summary          = "A wrapper of Armgmax's WhisperKit for CocoaPods."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Re-bundling WhisperKit (https://github.com/argmaxinc/WhisperKit) for use in CocoaPods. This allows
  it to be used in legacy CocoaPods projects that do not support Swift Package Manager, or React Native.
                       DESC

  s.homepage         = 'https://github.com/seb-sep/cocoa-whisper'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '59621473' => '59621473+seb-sep@users.noreply.github.com' }
  s.source           = { :git => 'https://github.com/seb-sep/cocoa-whisper.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '16.0'

  s.source_files = 'cocoa-whisper/**/*.swift'
  # s.source_files = 'cocoa-whisper/deps/**/*.swift'

  s.swift_version = '5.0'

  # s.resource_bundles = {
  #   'cocoa-whisper' => ['cocoa-whisper/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
