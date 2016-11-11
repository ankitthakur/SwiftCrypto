import Foundation
import Security


// Supported ECC Keys for Suite-B from RFC 4492 section 5.1.1.
// default is currently kSecp256r1
internal let kSecp192r1:Int32 =  192
internal let kSecp256r1:Int32 =  256
internal let kSecp384r1:Int32 =  384
internal let kSecp521r1:Int32 =  521

// Boundaries for RSA KeySizes - default is currently 2048
// RSA keysizes must be multiples of 8
internal let kSecRSAMin:Int32  =  1024
internal let kSecRSA2048:Int32 =  2048
internal let kSecRSAMax:Int32  =  4096

internal let byteSize:Int32 = 8;

internal let kECKeySize:Int32 = kSecp256r1; // Key size for the EC keypairs.
internal let kECKeySizeBytes:Int32 = kECKeySize / byteSize;

internal let kRSAKeySize:Int32 = kSecRSAMin; // Key size for the RSA keypairs.
internal let kRSAKeySizeBytes:Int32 = kRSAKeySize / byteSize;

public enum CryptoType{
    case ec
    case rsa
}

/// Key Size to generate keypair.
public enum CryptoSize{
    case ec192
    case ec256
    case ec384
    case ec521
    case rsa1024
    case rsa2048
    case rsa4096
}

public enum KeyFormat{
    case none
    case pem
}
open class SwiftCrypto
{
    
    open var publicKey:SecKey?
    open var privateKey:SecKey?
    open var keyType:CryptoType?
    
    public init(){
        
    }
    
    /// Generate a private/public keypair, containing the requested key size in bits.
    ///
    /// - parameters:
    ///   - type: Crypto type is either EC or RSA.
    ///   - size: For EC Type, size is 192, 256, 384 and 521. And for RSA Type, size is 1024, 2048 and 4096. If any of the size mismatch, then EC's default value will be EC256 and for RSA it is RSA1024.
    ///   - error: Error pointer, if any of the error occur during generating public/private key pair.
    
    open func generateKeyPair(_ type:CryptoType, size:CryptoSize, error:NSErrorPointer) -> Bool{
        
        let keySize:Int32 = {
            if type == .ec
            {
                if size == .ec192{
                    return kSecp192r1
                }
                else if size == .ec256{
                    return kSecp256r1
                }
                else if size == .ec384{
                    return kSecp384r1
                }
                else if size == .ec521{
                    return kSecp521r1
                }
                else {
                    return kECKeySize
                }
            }
            else{
                if size == .rsa1024{
                    return kSecRSAMin
                }
                else if size == .rsa2048{
                    return kSecRSA2048
                }
                else if size == .rsa4096{
                    return kSecRSAMax
                }
                else {
                    return kRSAKeySize
                }
            }
        }()
        
        let keyType:String = {
            if type == .ec
            {
                return kSecAttrKeyTypeEC as String
            }
            else{
                return kSecAttrKeyTypeRSA as String
            }
        }()
        
        
        
        self.keyType = type
        
        let params:NSMutableDictionary = NSMutableDictionary(capacity: 0)
        params[kSecAttrKeyType as String] = keyType
        params[kSecAttrKeySizeInBits as String] = NSNumber(value: keySize)
        
        // generate key pair
        let status:OSStatus = SecKeyGeneratePair(params as CFDictionary, &publicKey, &privateKey)
        
        var isKeyGenerated:Bool = false
        
        if status == errSecSuccess {
            isKeyGenerated = true
        }
        else{
            error?.pointee = NSError(domain: "Crypto Error", code: 111, userInfo: [NSLocalizedDescriptionKey:"Error while generating key pair"])
        }
        
        return isKeyGenerated
    }
    
    /// Convert SecKey to public key string format
    ///
    /// - parameters:
    ///   - type: Crypto type is either EC or RSA.
    ///   - format: PEM format or None. For None, "-----BEGIN PUBLIC KEY----" "------END PUBLIC KEY-----" will not get appear.
    ///   - publicKey: Public Key of SecKey type. 
    
    open class func publicKeyString(_ type:CryptoType, format:KeyFormat, publicKey:SecKey) -> String? {
        
        
        let encodedData:NSMutableData = NSMutableData()
        
        if type == .ec {
            guard let pubKeyBits:Data = SwiftCrypto.ECPublicKeyBitsFromKey(publicKey) else {
                return nil
            }
            encodedData.append(pubKeyBits as Data)
        }
        else if type == .rsa{
            guard let pubKeyBits:Data = SwiftCrypto.RSAPublicKeyBitsFromKey(publicKey) else {
                return nil
            }
            encodedData.append(pubKeyBits as Data)
            
        }
        
        let encodedString:String = String(data: encodedData.base64EncodedData(options: .lineLength64Characters), encoding: .utf8)!
        
        if format == .none {
            return encodedString
        }
        
        let pemString =  String(format: "-----BEGIN PUBLIC KEY-----\n%@\n-----END PUBLIC KEY-----", encodedString)
        
        return pemString
    }
    
    class func publicKeyInData(_ queryPublicKey:[String:AnyObject], secKey:SecKey) -> Data? {
        
        // Temporarily add key to the Keychain, return as data:
        var attributes:[String:AnyObject] = queryPublicKey
        attributes[kSecValueRef as String] = secKey
        attributes[kSecReturnData as String] = NSNumber(value: true)
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAlways as NSString
        
        var sanityCheck:OSStatus = noErr
        var result:CFTypeRef?
        var publicKeyBits:Data?
        sanityCheck = SecItemAdd(attributes as CFDictionary, &result)
        
        if sanityCheck == errSecSuccess {
            publicKeyBits = result as? Data
            SecItemDelete(queryPublicKey as CFDictionary)
        }
        else{
            print(keychainErrorMessage(sanityCheck))
        }
        
        return publicKeyBits
    }
    
    class func keychainErrorMessage(_ errorCode:OSStatus) -> String{
        
        var errorMessage:String = "unknown";
        switch (errorCode) {
        case errSecUnimplemented:
            errorMessage = "errSecUnimplemented: Function or operation not implemented.";
            break;
            
        case errSecIO:
            errorMessage = "errSecIO : I/O error (bummers)";
            break;
            
        case errSecOpWr:
            errorMessage = "errSecOpWr: file already open with with write permission";
            break;
            
        case errSecParam:
            errorMessage = "errSecParam: One or more parameters passed to a function where not valid.";
            break;
            
        case errSecAllocate:
            errorMessage = "errSecAllocate: Failed to allocate memory.";
            break;
            
        case errSecUserCanceled:
            errorMessage = "errSecUserCanceled: User canceled the operation.";
            break;
            
        case errSecBadReq:
            errorMessage = "errSecBadReq: Bad parameter or invalid state for operation.";
            break;
            
        case errSecInternalComponent:
            errorMessage = "errSecInternalComponent";
            break;
            
        case errSecNotAvailable:
            errorMessage = "errSecNotAvailable: No keychain is available. You may need to restart your computer.";
            break;
            
        case errSecDuplicateItem:
            errorMessage = "errSecDuplicateItem: The specified item already exists in the keychain.";
            break;
            
        case errSecItemNotFound:
            errorMessage = "errSecItemNotFound: The specified item could not be found in the keychain.";
            break;
            
        case errSecInteractionNotAllowed:
            errorMessage = "errSecInteractionNotAllowed: User interaction is not allowed.";
            break;
            
        case errSecDecode:
            errorMessage = "errSecDecode: Unable to decode the provided data.";
            break;
            
        case errSecAuthFailed:
            errorMessage = "errSecAuthFailed: The user name or passphrase you entered is not correct.";
            break;
            
        default:
            errorMessage = "No error.";
            break;
        }
        
        return errorMessage;
        
    }
    
    class func RSAPublicKeyBitsFromKey(_ secKey:SecKey) -> Data? {
        
        var queryPublicKey:[String:AnyObject] = [:]
        queryPublicKey[kSecClass as String] = kSecClassKey as NSString
        queryPublicKey[kSecAttrKeyType as String] = kSecAttrKeyTypeRSA as NSString
        
        return SwiftCrypto.publicKeyInData(queryPublicKey, secKey: secKey)
    }
    
    class func ECPublicKeyBitsFromKey(_ secKey:SecKey) -> Data? {
        
        var queryPublicKey:[String:AnyObject] = [:]
        queryPublicKey[kSecClass as String] = kSecClassKey as NSString
        queryPublicKey[kSecAttrKeyType as String] = kSecAttrKeyTypeEC as NSString
        
        return SwiftCrypto.publicKeyInData(queryPublicKey, secKey: secKey)
    }
    
    
}
