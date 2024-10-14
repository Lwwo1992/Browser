//
//  StringExtension.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/12.
//

import Foundation

extension String {
    var maskedAccount: String {
        guard count > 4 else { return self }

        let startIndex = index(self.startIndex, offsetBy: 3)
        let endIndex = index(self.endIndex, offsetBy: -4)

        let maskedRange = startIndex ..< endIndex
        let mask = String(repeating: "*", count: distance(from: startIndex, to: endIndex))

        return replacingCharacters(in: maskedRange, with: mask)
    }
}
