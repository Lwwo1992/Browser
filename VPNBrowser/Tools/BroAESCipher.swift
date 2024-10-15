//
//  BroAESCipher.swift
//  VPNBrowser
//
//  Created by wei Chen on 2024/10/14.
//

import UIKit
 
import Foundation
import CommonCrypto

class BroAESCipher {
    
    static let KEY = "1234567890202209" // 密钥
    static let IV = "1234567890202209"  // IV向量

    // AES 加密方法
    static func encrypt(_ data: String) -> String? {
        guard let dataBytes = data.data(using: .utf8) else { return nil }
        let keyData = KEY.data(using: .utf8)!
        let ivData = IV.data(using: .utf8)!
        
        let bufferSize = dataBytes.count + kCCBlockSizeAES128
        var buffer = Data(count: bufferSize)
        var numBytesEncrypted: size_t = 0
        
        let cryptStatus = buffer.withUnsafeMutableBytes { bufferBytes in
            dataBytes.withUnsafeBytes { dataBytes in
                keyData.withUnsafeBytes { keyBytes in
                    ivData.withUnsafeBytes { ivBytes in
                        CCCrypt(CCOperation(kCCEncrypt),
                                CCAlgorithm(kCCAlgorithmAES128),
                                CCOptions(kCCOptionPKCS7Padding),
                                keyBytes.baseAddress, kCCKeySizeAES128,
                                ivBytes.baseAddress,
                                dataBytes.baseAddress, dataBytes.count,
                                bufferBytes.baseAddress, bufferSize,
                                &numBytesEncrypted)
                    }
                }
            }
        }
        
        if cryptStatus == kCCSuccess {
            buffer.count = numBytesEncrypted
            return buffer.base64EncodedString() // 返回Base64加密后的字符串
        }
        return nil
    }

    // AES 解密方法
    static func decrypt(_ data: String) -> String? {
        guard let dataBytes = Data(base64Encoded: data) else { return nil }
        let keyData = KEY.data(using: .utf8)!
        let ivData = IV.data(using: .utf8)!
        
        let bufferSize = dataBytes.count + kCCBlockSizeAES128
        var buffer = Data(count: bufferSize)
        var numBytesDecrypted: size_t = 0
        
        let cryptStatus = buffer.withUnsafeMutableBytes { bufferBytes in
            dataBytes.withUnsafeBytes { dataBytes in
                keyData.withUnsafeBytes { keyBytes in
                    ivData.withUnsafeBytes { ivBytes in
                        CCCrypt(CCOperation(kCCDecrypt),
                                CCAlgorithm(kCCAlgorithmAES128),
                                CCOptions(kCCOptionPKCS7Padding),
                                keyBytes.baseAddress, kCCKeySizeAES128,
                                ivBytes.baseAddress,
                                dataBytes.baseAddress, dataBytes.count,
                                bufferBytes.baseAddress, bufferSize,
                                &numBytesDecrypted)
                    }
                }
            }
        }
        
        if cryptStatus == kCCSuccess {
            buffer.count = numBytesDecrypted
            return String(data: buffer, encoding: .utf8) // 返回解密后的字符串
        }
        return nil
    }
}
