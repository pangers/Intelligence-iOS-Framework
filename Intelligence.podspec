#
# Be sure to run `pod lib lint Intelligence.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'IntelligenceSDK'
  s.version          = '1.2.0'
  s.summary          = 'A short description of Intelligence.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, dont worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
    TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://git-apac.internal.tigerspike.com/phoenix/Phoenix-Intelligence-iOS-SDK'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Chethan' => 'Chethan.palaksha@tigerspike.com' }
  s.source           = { :git => 'https://git.tigerspike.com/phoenix/Phoenix-Intelligence-iOS-SDK.git', :branch=>'Swift-3.0', :tag => '1.2.0' }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'IntelligenceSDK/IntelligenceSDK/**/*'

  # s.resource_bundles = {
  #   'Intelligence' => ['IntelligenceSDK/IntelligenceSDK/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
