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

    // 扩展添加计算与当前时间天数差的属性
    var daysFromNow: Int {
        // 将字符串转换为 Int64 时间戳
        guard let timestamp = Int64(self) else { return 0 }

        // 将时间戳转换为秒
        let timestampInSeconds = TimeInterval(timestamp) / 1000

        // 将时间戳转换为 Date 对象
        let eventDate = Date(timeIntervalSince1970: timestampInSeconds)

        // 获取当前日期
        let currentDate = Date()

        // 计算两个日期之间的天数差
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: eventDate, to: currentDate)

        return components.day ?? 0
    }
}

extension UIImageView {
    func setImage(with url: URL?, placeholder: String? = nil) {
        let placeholderImage = placeholder != nil ? UIImage(named: placeholder!) : nil

        kf.setImage(
            with: url,
            placeholder: placeholderImage
        )
    }
}

extension URL {
    var typeIdentifier: String? {
        return (try? resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier
    }

    var localizedName: String? {
        return (try? resourceValues(forKeys: [.localizedNameKey]))?.localizedName
    }
}
