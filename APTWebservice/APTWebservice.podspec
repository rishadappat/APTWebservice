Pod::Spec.new do |s|
  s.name             = 'APTWebservice'
  s.version          = '0.1.0'
  s.summary          = 'Simple Webservice client in swift'
  s.swift_version      = "4.0"
  s.description      = <<-DESC
A WebService client written in swift
                       DESC

  s.homepage         = 'https://github.com/rishadappat/APTWebservice'
  s.license          = { :type => 'GNU', :file => 'LICENSE' }
  s.author           = { 'Rishad Appat' => 'rishadappat@gmail.com' }
  s.source           = { :git => 'https://github.com/rishadappat/APTWebservice.git', :tag => "#{s.version}" }

  s.ios.deployment_target = '10.0'
  s.source_files = "APTWebservice/APTWebservice/*.{swift,plist,h}"

end
