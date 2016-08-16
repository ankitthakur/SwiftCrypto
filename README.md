# SwiftCrypto

[![CI Status](http://img.shields.io/travis/Ankitthakur/SwiftCrypto.svg?style=flat)](https://travis-ci.org/Ankitthakur/SwiftCrypto)
[![Version](https://img.shields.io/cocoapods/v/SwiftCrypto.svg?style=flat)](http://cocoadocs.org/docsets/SwiftCrypto)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/SwiftCrypto.svg?style=flat)](http://cocoadocs.org/docsets/SwiftCrypto)
[![Platform](https://img.shields.io/cocoapods/p/SwiftCrypto.svg?style=flat)](http://cocoadocs.org/docsets/SwiftCrypto)

## Description

**SwiftCrypto** is currently supporting Elliptic Curve Crypto (ECC) and RSA public private key generation and conversion to PEM format.

## Usage

```swift
// Generate ECC Public Private Key
let crypto1 = SwiftCrypto()
crypto1.generateKeyPair(type: .EC, error: &error)
print(error)
print(crypto1.privateKey)
print(crypto1.publicKey)

// Generate RSA Public Private Key
let crypto2 = SwiftCrypto()
crypto2.generateKeyPair(type: .RSA, error: &error)
print(error)
print(crypto2.privateKey)
print(crypto2.publicKey)

// converting ECC Public Key to PEM Format
SwiftCrypto.pemFormatKey(type: .EC, publicKey:crypto1.publicKey!)

// converting RSA Public Key to PEM Format
SwiftCrypto.pemFormatKey(type: .RSA, publicKey:crypto2.publicKey!)
```

## Installation

**SwiftCrypto** is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SwiftCrypto'
```

**SwiftCrypto** is also available through [Carthage](https://github.com/Carthage/Carthage).
To install just write into your Cartfile:

```ruby
github "Ankitthakur/SwiftCrypto"
```

**SwiftCrypto** can also be installed manually. Just download and drop `Sources` folders in your project.

## Author

Ankit Thakur, ankitthakur85@icloud.com

## Contributing

We would love you to contribute to **SwiftCrypto**, check the [CONTRIBUTING](https://github.com/Ankitthakur/SwiftCrypto/blob/master/CONTRIBUTING.md) file for more info.

## License

**SwiftCrypto** is available under the MIT license. See the [LICENSE](https://github.com/Ankitthakur/SwiftCrypto/blob/master/LICENSE.md) file for more info.
