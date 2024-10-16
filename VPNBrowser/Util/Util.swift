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
                let view = DownloadView(frame: CGRect(x: 0, y: 0, width: Util.deviceWidth, height: 260))
                view.model = model
                return view
            }
        case "applet":
            break
        default:
            break
        }
    }
}
