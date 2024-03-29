#
# Be sure to run `pod lib lint LacrasteCloud.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LacrasteCloud'
  s.version          = '0.1.2'
  s.summary          = 'LacrasteCloud makes CloudKit operations easier.'
  
# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  LacrasteCloud makes CloudKit CRUD operations easier and less verbose It can be done some pagination and sort.
                       DESC

  s.homepage         = 'https://github.com/giovaninb/LacrasteCloud'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Giovani Bettoni' => 'giovanibettoni@icloud.com' }
  s.source           = { :git => 'https://github.com/giovaninb/LacrasteCloud.git', :tag => s.version }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '14.0'

  s.source_files = 'LacrasteCloud/Classes/**/*'
  
  # s.resource_bundles = {
  #   'LacrasteCloud' => ['LacrasteCloud/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
