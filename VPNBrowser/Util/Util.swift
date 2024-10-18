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
//            Util.topViewController().popup.bottomSheet {
//                let view = DownloadView(frame: CGRect(x: 0, y: 0, width: Util.deviceWidth, height: 260))
//                view.model = model
//                return view
//            }
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

    /// 验证密码正确性
    static func isPasswordValid(_ password: String) -> Bool {
        // 确保密码长度大于6位
        if password.count <= 6 {
            HUD.showTipMessage("密码必须大于6位")
            return false
        }

        // 只能包含英文字母和数字
        let allowedCharacters = CharacterSet.alphanumerics

        // 遍历密码，检查是否每个字符都在 allowedCharacters 中
        for char in password.unicodeScalars {
            if !allowedCharacters.contains(char) {
                HUD.showTipMessage("密码不能包含特殊字符或中文")
                return false
            }
        }

        return true
    }
}
