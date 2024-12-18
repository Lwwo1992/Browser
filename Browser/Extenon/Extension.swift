//
//  StringExtension.swift
//  Browser
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

extension Date {
    func daysFromNow() -> Int {
        let calendar = Calendar.current
        let currentDate = Date()
        let components = calendar.dateComponents([.day], from: self, to: currentDate)
        return components.day ?? 0
    }

    /// 计算从当前时间到指定日期的时间差，并返回一个描述字符串
    func timeAgoDescription() -> String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(self)

        // 使用 DateComponentsFormatter 来将时间差格式化为易读的形式
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day]
        formatter.maximumUnitCount = 1 // 只显示最大的时间单位
        formatter.unitsStyle = .full // 显示完整单位，如 "minutes" 而不是 "min"

        // 如果时间差超过一天，显示具体日期
        if timeInterval > 86400 { // 86400 秒 = 1 天
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium // 显示如 "Oct 20, 2014"
            return dateFormatter.string(from: self)
        }

        // 获取时间差的格式化结果
        return (formatter.string(from: timeInterval) ?? "")
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

extension Date {
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }

    func formattedDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd"
        return formatter.string(from: self)
    }
}

extension TimeInterval {
    var asDate: Date {
        return Date(timeIntervalSince1970: self / 1000)
    }

    var formatted: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: asDate)
    }
}

extension Array where Element == HistoryModel {
    func groupedByDate() -> [Date: [HistoryModel]] {
        let calendar = Calendar.current
        var groupedHistory: [Date: [HistoryModel]] = [:]

        for history in self {
            let date = Date(timeIntervalSince1970: history.timestamp)
            let dateWithoutTime = calendar.startOfDay(for: date)

            if groupedHistory[dateWithoutTime] != nil {
                groupedHistory[dateWithoutTime]?.append(history)
            } else {
                groupedHistory[dateWithoutTime] = [history]
            }
        }

        return groupedHistory
    }
}

public extension UIImage {
    static var icon: UIImage? {
        if let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let lastIcon = iconFiles.last {
            return UIImage(named: lastIcon)
        }
        return nil
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
