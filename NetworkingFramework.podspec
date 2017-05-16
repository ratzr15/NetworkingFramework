Pod::Spec.new do |s|
s.name             = 'NetworkingFramework'
s.version          = '0.2.0'
s.summary          = 'The framework handles Network Rechabllity while making network calls and serializes the data.'

s.description      = <<-DESC

Networking Manager - makes network request {GET / POST}.
Networking Manager - Fully Swift
Networking Manager - Network Rechablity using "https://github.com/ashleymills/Reachability.swift"


DESC

s.homepage         = 'https://github.com/ratzr15/NetworkingFramework'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'Rathish Kannan' => 'rathishnk@hotmail.co.in' }
s.source           = { :git => 'https://github.com/ratzr15/NetworkingFramework.git', :tag =>' 0.2.0' }

s.ios.deployment_target = '9.0'
s.source_files = 'NetworkingFramework/*.{swift,plist, .h}'

end
