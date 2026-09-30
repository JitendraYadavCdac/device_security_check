Pod::Spec.new do |s|
  s.name             = 'device_security_scan'
  s.version          = '0.1.0'
  s.summary          = 'Basic device security checks for Flutter.'
  s.description      = <<-DESC
Basic device security checks for rooted/jailbroken devices, emulators and debuggers.
DESC
  s.homepage         = 'https://github.com/your-org/device_security_scan'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Name' => 'you@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.ios.deployment_target = '13.0'
  s.dependency 'Flutter'
  s.swift_version = '5.0'
end
