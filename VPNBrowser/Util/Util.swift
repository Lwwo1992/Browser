//
//  Util.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/15.
//

import Foundation

extension Util {
    static func getCompleteImageUrl(from path: String?) -> URL? {
        guard let path = path else {
            print("Invalid path.")
            return nil
        }

        let components = path.split(separator: "/")
        guard let firstComponent = components.first else {
            print("Invalid path components.")
            return nil
        }

        if let guideBucketInfo = S.Config.anonymous?.bucketMap?[String(firstComponent)],
           let imageUrl = guideBucketInfo.imageUrl {
            let modifiedUrl = imageUrl.replacingOccurrences(of: "/\(firstComponent)", with: "")
            let urlString = modifiedUrl + path

            return URL(string: urlString)
        } else {
            print("No corresponding guide found in bucketMap or image URL is missing.")
            return nil
        }
    }

    static func formattedTime(from timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date)
    }

    /// 创建文件夹
    static func createFolderIfNotExists(_ url: URL) {
        if FileManager.default.fileExists(atPath: url.path) == false {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
            } catch let error {
                debugPrint(error.localizedDescription)
            }
        }
    }

    /// 获取 documents 目录
    static var documentsPath: String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }

    static func guideItemTap(_ model: GuideItem) {
        switch model.type {
        case "h5":
            let vc = BrowserWebViewController()
            vc.path = model.downloadUrl ?? ""
            Util.topViewController().navigationController?.pushViewController(vc, animated: true)
        case "app":
            Util.topViewController().popup.bottomSheet {
                let view = DownloadBottomSheetView(frame: CGRect(x: 0, y: 0, width: Util.deviceWidth, height: 260))
                view.model = model
                return view
            }
            break
        case "applet":
            break
        default:
            break
        }
    }

    static func formatFileSize(_ size: Int64) -> String {
        let units = ["B", "KB", "MB", "GB"]
        var sizeInUnit = Double(size)
        var unitIndex = 0

        while sizeInUnit >= 1024 && unitIndex < units.count - 1 {
            sizeInUnit /= 1024
            unitIndex += 1
        }

        if sizeInUnit.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f %@", sizeInUnit, units[unitIndex])
        } else {
            return String(format: "%.2f %@", sizeInUnit, units[unitIndex])
        }
    }

    static func isValidPassword(_ password: String) -> Bool {
        // 检测密码长度是否在 8 到 16 位之间
        if password.count < 8 || password.count > 16 {
            HUD.showTipMessage("密码必须是 8 到 16 位")
            return false
        }

        // 纯数字检测正则
        let pureNumberRegex = "^[0-9]{8,16}$"

        // 判断是否为纯数字
        let isPureNumber = NSPredicate(format: "SELF MATCHES %@", pureNumberRegex).evaluate(with: password)
        if isPureNumber {
            HUD.showTipMessage("密码不能是纯数字")
            return false
        }

        // 检查是否包含字母
        let containsLetterRegex = ".*[A-Za-z]+.*"
        let containsLetter = NSPredicate(format: "SELF MATCHES %@", containsLetterRegex).evaluate(with: password)
        if !containsLetter {
            HUD.showTipMessage("密码必须包含字母")
            return false
        }

        // 检查是否包含数字
        let containsNumberRegex = ".*\\d+.*"
        let containsNumber = NSPredicate(format: "SELF MATCHES %@", containsNumberRegex).evaluate(with: password)
        if !containsNumber {
            HUD.showTipMessage("密码必须包含数字")
            return false
        }

        // 检查是否包含特殊字符
        let containsSpecialCharRegex = ".*[!@#$%^&*]+.*"
        let containsSpecialChar = NSPredicate(format: "SELF MATCHES %@", containsSpecialCharRegex).evaluate(with: password)
        if !containsSpecialChar {
            HUD.showTipMessage("密码必须包含特殊字符")
            return false
        }

        return true
    }

    /// 根据路径 计算 数据大小
    static func getFileSize(dbPath: String) -> Int64? {
        let fileManager = FileManager.default

        // 检查文件是否存在
        if fileManager.fileExists(atPath: dbPath) {
            do {
                // 获取文件属性
                let attributes = try fileManager.attributesOfItem(atPath: dbPath)

                // 获取文件大小
                if let fileSize = attributes[.size] as? Int64 {
                    return fileSize
                }
            } catch {
                print("Error while getting file size: \(error)")
            }
        }
        return nil
    }

    static func createQRCodeImage(content: String) -> UIImage? {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        let data = content.data(using: .utf8)
        filter.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        guard let ciImage = filter.outputImage?.transformed(by: transform) else {
            return nil
        }
        return UIImage(ciImage: ciImage)
    }

    static func formatTime(_ timeInterval: TimeInterval) -> String {
        let days = Int(timeInterval) / 86400
        let hours = (Int(timeInterval) % 86400) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60

        if days > 0 {
            return String(format: "%02d天 %02d:%02d:%02d", days, hours, minutes, seconds)
        } else if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    static func formatSeconds(_ timeInterval: TimeInterval) -> String {
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d", seconds)
    }
}
