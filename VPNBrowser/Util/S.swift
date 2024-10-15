//
//  Config.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/11.
//

import Foundation

struct S {
    struct Table {
        /// 系统配置
        static let configInfo = "configTable"
        /// 个人信息
        static let loginInfo = "loginInfoTable"
        /// 搜索历史
        static let searchHistory = "searchHistoryTable"
        /// 浏览历史
        static let browseHistory = "browseHistoryTable"
        /// 收藏
        static let collect = "collectTable"
        /// 书签
        static let bookmark = "bookmarkTable"
    }

    struct Files {
        static var imageURL: URL {
            let libraryURL = URL(fileURLWithPath: Util.documentsPath)
            return libraryURL.appendingPathComponent("imageURL", isDirectory: true)
        }
    }

    struct Config {
        static var maxAppNum = 5
        static var defalutUrl = ""
        static var loginType: [LoginType]?
        static var anonymous: AnonymousConfigModel?
        /// 开启无痕浏览
        static var openNoTrace: Bool = false

        /// 导航模式
        static var mode: WebMode = .guide
    }
}

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

    static var documentsPath: String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
}
