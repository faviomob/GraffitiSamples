Pod::Spec.new do |s|
  s.name             = 'Graffiti'
  s.version          = '1.0.0'
  s.summary          = 'Lightweight iOS framework for creating codeless native apps.'
  s.homepage         = 'http://graffiti.m8labs.com'
  s.license          = { :type => 'Commercial', :text => 'See http://graffiti.m8labs.com/terms' }
  s.author           = { 'M8 Labs' => 'm8labs.io@gmail.com' }
  s.source           = { :http => 'https://github.com/m8labs/GraffitiSamples/raw/gh-pages/bin/iOS/1.0.0-alpha.1/Graffiti.framework.zip' }

  s.ios.deployment_target = '10.0'
  s.ios.vendored_frameworks = 'Graffiti.framework'

  s.dependency 'Groot'
  s.dependency 'AlamofireImage', '~> 3.3'

end
