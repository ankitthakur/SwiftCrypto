/*
 This source file is part of the Swift.org open source project
 Copyright 2015 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception
 See http://swift.org/LICENSE.txt for license information
 See http://swift.org/CONTRIBUTORS.txt for Swift project authors
 */

import PackageDescription

/*
#if os(OSX)
let provider = .Brew("openssl")
let pkgConfig = "open-ssl"
    
#elseif os(Linux)
let provider = .Apt("openssl libssl-dev")
let pkgConfig = "openssl"
    
#else
fatalError("Unsupported OS")
#endif
*/
let package = Package(
    name: "SwiftCrypto",
    dependencies: [
       // .Package(url: "https://github.com/open-swift/C7.git", majorVersion: 0, minor: 9),
        //.Package(url: "https://github.com/Zewo/COpenSSL.git", majorVersion: 0, minor: 6)
    
    pkgConfig: "open-ssl",
    providers: [
        .Brew("openssl")
    ]
        ]
)
