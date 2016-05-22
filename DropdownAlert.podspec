#
# Be sure to run `pod lib lint DropdownAlert.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DropdownAlert'
  s.version          = '1.0.3'
  s.summary          = 'Customizable, simple, dropdown alert written in Swift.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
DropdownAlert offers a simple, easy-to-use alternative to RKDropdownAlert, written entirely in Swift. DropdownAlert is responsive and powered by Facebook's pop animation engine.
                       DESC

  s.homepage         = 'https://github.com/startupthekid/DropdownAlert'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Brendan Conron' => 'conronb@gmail.com' }
  s.source           = { :git => 'https://github.com/startupthekid/DropdownAlert.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/startupthekid'

  s.ios.deployment_target = '8.0'

  s.source_files = 'DropdownAlert/Classes/*'
  
  s.resource_bundles = {
    'DropdownAlert' => ['DropdownAlert/Assets/*.*']
  }

  s.dependency 'pop'
end
