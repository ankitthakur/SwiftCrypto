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
internal let kSecRSAMin:Int32 =  1024
internal let kSecRSAMax:Int32 =  4096

internal let byteSize:Int32 = 8;

internal let kECKeySize:Int32 = kSecp256r1; // Key size for the EC keypairs.
internal let kECKeySizeBytes:Int32 = kECKeySize / byteSize;

internal let kRSAKeySize:Int32 = kSecRSAMin; // Key size for the RSA keypairs.
internal let kRSAKeySizeBytes:Int32 = kRSAKeySize / byteSize;

public enum CryptoType{
    case EC
    case RSA
}
public class SwiftCrypto
{
    
    public var publicKey:SecKey?
    public var privateKey:SecKey?
    public var keyType:CryptoType?
    
    public init(){
        
    }
    
    public func generateKeyPair(type:CryptoType, error:NSErrorPointer) -> Bool{
        
        let keySize:Int32 = {
            if type == .EC
            {
                return kECKeySize
            }
            else{
                return kRSAKeySize
            }
        }()
        
        let keyType:String = {
            if type == .EC
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
    
    public func pemFormatKey(type:CryptoType, publicKey:SecKey) -> String? {
        
        
        let encodedData:NSMutableData = NSMutableData()
        
        if type == .EC {
            guard let pubKeyBits:NSData = SwiftCrypto.getECPublicKeyBitsFromKey(secKey: publicKey) else {
                return nil
            }
            encodedData.append(pubKeyBits as Data)
        }
        else if type == .RSA{
            guard let pubKeyBits:NSData = SwiftCrypto.getRSAPublicKeyBitsFromKey(secKey: publicKey) else {
                return nil
            }
            encodedData.append(pubKeyBits as Data)
            
        }
        
        let encodedString:String = String(data: encodedData.base64EncodedData(options: .lineLength64Characters), encoding: .utf8)!
        
        let pemString =  String(format: "-----BEGIN PUBLIC KEY-----\n%@\n-----END PUBLIC KEY-----", encodedString)
        
        return pemString
    }
    
    public class func publicKeyInData(queryPublicKey:[String:AnyObject], secKey:SecKey) -> NSData? {
        
        // Temporarily add key to the Keychain, return as data:
        var attributes:[String:AnyObject] = queryPublicKey
        attributes[kSecValueRef as String] = secKey
        attributes[kSecReturnData as String] = NSNumber(value: true)
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAlways as NSString
        
        var sanityCheck:OSStatus = noErr
        var result:CFTypeRef?
        var publicKeyBits:NSData?
        sanityCheck = SecItemAdd(attributes as CFDictionary, &result)
        
        if sanityCheck == errSecSuccess {
            publicKeyBits = result as? NSData
            SecItemDelete(queryPublicKey as CFDictionary)
        }
        else{
            print(keychainErrorMessage(errorCode:sanityCheck))
        }
        
        return publicKeyBits
    }
    
    
    
    
    public class func keychainErrorMessage(errorCode:OSStatus) -> String{
        
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
    
    public class func getRSAPublicKeyBitsFromKey(secKey:SecKey) -> NSData? {
        
        var queryPublicKey:[String:AnyObject] = [:]
        queryPublicKey[kSecClass as String] = kSecClassKey as NSString
        queryPublicKey[kSecAttrKeyType as String] = kSecAttrKeyTypeRSA as NSString
        
        return SwiftCrypto.publicKeyInData(queryPublicKey: queryPublicKey, secKey: secKey)
    }
    
    public class func getECPublicKeyBitsFromKey(secKey:SecKey) -> NSData? {
        
        var queryPublicKey:[String:AnyObject] = [:]
        queryPublicKey[kSecClass as String] = kSecClassKey as NSString
        queryPublicKey[kSecAttrKeyType as String] = kSecAttrKeyTypeEC as NSString
        
        return SwiftCrypto.publicKeyInData(queryPublicKey: queryPublicKey, secKey: secKey)
    }
    
    
}
