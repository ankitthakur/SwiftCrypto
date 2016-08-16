// SwiftCrypto iOS Playground

import UIKit
import SwiftCrypto

var str = "Hello, playground"

var error:NSError?
let crypto1 = SwiftCrypto()
crypto1.generateKeyPair(type: .EC, error: &error)
print(error)
print(crypto1.privateKey)
print(crypto1.publicKey)

let crypto2 = SwiftCrypto()
crypto2.generateKeyPair(type: .RSA, error: &error)
print(error)
print(crypto2.privateKey)
print(crypto2.publicKey)
