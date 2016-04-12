Pod::Spec.new do |s|
  s.name                  = "PRSlideView-Swift"
  s.version               = "0.2.2b"
  s.summary               = "Slide view with UIKit-like methods, delegate and data source protocol."
  s.homepage              = "https://github.com/Elethom/PRSlideView-Swift"
  s.license               = { :type => "MIT", :file => "LICENSE" }
  s.author                = { "Elethom Hunter" => "elethomhunter@gmail.com" }
  s.social_media_url      = "https://twitter.com/ElethomHunter"
  s.platform              = :ios 
  s.ios.deployment_target = 7.0
  s.source                = { :git => "https://github.com/Elethom/PRSlideView-Swift.git", :tag => s.version }
  s.source_files          = "Classes/*.swift"
  s.requires_arc          = true
end
