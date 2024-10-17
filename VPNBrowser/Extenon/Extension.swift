//
//  StringExtension.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/12.
//

import Foundation

extension String {
    var maskedAccount: String {
        // 确保字符串长度大于 4
        guard count > 4 else { return self }

        // 保留开头 3 个字符，结尾保留 4 个字符
        let startIndex = index(self.startIndex, offsetBy: 3)
        let endIndex = index(self.endIndex, offsetBy: -4)

        // 计算需要遮掩的范围，减少 * 数量
        let maskedRange = startIndex ..< endIndex
        let originalMiddle = self[maskedRange]

        // 将原中间部分的一半替换为 *
        let middleMaskCount = max(1, originalMiddle.count / 2) // 使用中间部分一半的长度
        let mask = String(repeating: "*", count: middleMaskCount)

        // 创建保留原字符的范围
        let unmaskedStartIndex = originalMiddle.index(originalMiddle.startIndex, offsetBy: middleMaskCount)
        let unmaskedMiddle = originalMiddle[unmaskedStartIndex ..< originalMiddle.endIndex]

        // 将中间部分的一半用 * 替换
        let maskedMiddle = mask + unmaskedMiddle

        return replacingCharacters(in: maskedRange, with: maskedMiddle)
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
