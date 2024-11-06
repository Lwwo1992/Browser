//
//  BroAESCipher.swift
//  Browser
//
//  Created by wei Chen on 2024/10/14.
//

import CommonCrypto
import Foundation

class EncryptUtil {
    static let key = "1234567890202209"
    static let iv = "1234567890202209"

    /// AES 加密 (NoPadding)
    /// - Parameter data: 需要加密的字符串
    /// - Returns: 加密后的 Base64 编码字符串
    static func encrypt(_ data: String) -> String {
        guard var dataBytes = data.data(using: .utf8) else { return "" }

        let blockSize = kCCBlockSizeAES128
        let dataLength = dataBytes.count

        // 处理 NoPadding，手动填充到 16 字节的倍数
        let paddingLength = blockSize - (dataLength % blockSize)
        if paddingLength > 0 {
            dataBytes.append(contentsOf: [UInt8](repeating: 0, count: paddingLength))
        }

        let keyBytes = [UInt8](key.utf8)
        let ivBytes = [UInt8](iv.utf8)

        var encryptedBytes = [UInt8](repeating: 0, count: dataBytes.count + blockSize)
        var encryptedLength: size_t = 0

        let status = CCCrypt(
            CCOperation(kCCEncrypt),
            CCAlgorithm(kCCAlgorithmAES),
            CCOptions(0), // NoPadding
            keyBytes,
            keyBytes.count,
            ivBytes,
            [UInt8](dataBytes),
            dataBytes.count,
            &encryptedBytes,
            encryptedBytes.count,
            &encryptedLength
        )

        guard status == kCCSuccess else {
            print("Encryption failed with status: \(status)")
            return ""
        }

        let encryptedData = Data(bytes: encryptedBytes, count: encryptedLength)
        return encryptedData.base64EncodedString().trimmingCharacters(in: .whitespaces)
    }

    /// AES 解密 (NoPadding)
    /// - Parameter data: Base64 编码的加密字符串
    /// - Returns: 解密后的原始字符串
    static func desEncrypt(_ data: String) -> String? {
        guard let dataBytes = Data(base64Encoded: data) else { return nil }

        let keyBytes = [UInt8](key.utf8)
        let ivBytes = [UInt8](iv.utf8)

        var decryptedBytes = [UInt8](repeating: 0, count: dataBytes.count + kCCBlockSizeAES128)
        var decryptedLength: size_t = 0

        let status = CCCrypt(
            CCOperation(kCCDecrypt),
            CCAlgorithm(kCCAlgorithmAES),
            CCOptions(0), // NoPadding
            keyBytes,
            keyBytes.count,
            ivBytes,
            [UInt8](dataBytes),
            dataBytes.count,
            &decryptedBytes,
            decryptedBytes.count,
            &decryptedLength
        )

        guard status == kCCSuccess else {
            print("Decryption failed with status: \(status)")
            return nil
        }

        let decryptedData = Data(bytes: decryptedBytes, count: decryptedLength)
        return String(data: decryptedData, encoding: .utf8)?.trimmingCharacters(in: .whitespaces)
    }
}
