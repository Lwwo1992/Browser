//
//  TokenGenerator.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/15.
//

import Foundation
import SwiftJWT

class TokenGenerator {
//    private static let GRANT_CODE = "wkryw7roteux" // 测试环境
    private static let GRANT_CODE = "kiueQf44NtLu" // 正式环境
    private static let SECRET_KEY = "clientAccess_xysfkhdfw"
    private static let CLIENT_CODE = "browser"
    private static let outTime: TimeInterval = 60 * 60 * 100 // 过期时间，单位为秒
    private static var tokenGuide: String = ""
    private static var lastTimeGuide: TimeInterval = 0

    static func generateTokenGuide() -> String {
        let currentTime = Date().timeIntervalSince1970

        // 检查 token 是否过期
        if currentTime - lastTimeGuide > (outTime - 5) {
            tokenGuide = ""
        }

        if tokenGuide.isEmpty {
            // 指定 token 过期时间
            let expirationDate = Date(timeIntervalSinceNow: outTime)
            let claims = MyClaims(sub: GRANT_CODE,
                                  exp: expirationDate,
                                  clientCode: CLIENT_CODE,
                                  grantCode: GRANT_CODE,
                                  identity: "admin")

            var jwt = JWT(claims: claims)

            do {
                let secretData = SECRET_KEY.data(using: .utf8)!
                let jwtSigner = JWTSigner.hs512(key: secretData)
                tokenGuide = try jwt.sign(using: jwtSigner)
                lastTimeGuide = currentTime
            } catch {
                print("Failed to generate JWT: \(error)")
                return ""
            }
        }

        return tokenGuide
    }
}

struct MyClaims: Claims {
    let sub: String
    let exp: Date
    let clientCode: String
    let grantCode: String
    let identity: String
}
