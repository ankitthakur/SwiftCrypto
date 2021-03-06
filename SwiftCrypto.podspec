Pod::Spec.new do |s|
  s.name             = "SwiftCrypto"
  s.summary          = "SwiftCrypto is currently supporting Elliptic Curve Crypto (ECC) and RSA public private key generation and conversion to PEM format."
  s.version          = "0.0.1"
  s.homepage         = "https://github.com/Ankitthakur/SwiftCrypto"
  s.license          = 'MIT'
  s.author           = { "Ankit Thakur" => "ankitthakur85@icloud.com" }
  s.source           = {
    :git => "https://github.com/Ankitthakur/SwiftCrypto.git",
    :tag => s.version.to_s
  }
  s.social_media_url = 'https://twitter.com/Ankitthakur'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.2'

  s.requires_arc = true
  s.ios.source_files = 'Sources/{iOS,Shared}/**/*'
  s.tvos.source_files = 'Sources/{iOS,Shared}/**/*'
  s.osx.source_files = 'Sources/{Mac,Shared}/**/*'

  # s.ios.frameworks = 'UIKit', 'Foundation'
  # s.osx.frameworks = 'Cocoa', 'Foundation'

  # s.dependency 'Whisper', '~> 1.0'
end
