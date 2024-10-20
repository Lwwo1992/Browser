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
        /// 文件夹
        static let folder = "folderTable"
        /// 书签
        static let bookmark = "bookmarkTable"
        /// 下载
        static let download = "downloadTable"
    }

    struct Files {
        static var imageURL: URL {
            let libraryURL = URL(fileURLWithPath: Util.documentsPath)
            return libraryURL.appendingPathComponent("ImageURL", isDirectory: true)
        }

        static var downloads: URL {
            let libraryURL = URL(fileURLWithPath: Util.documentsPath)
            return libraryURL.appendingPathComponent("Downloads", isDirectory: true)
        }
    }

    struct Config {
        static var maxAppNum = 5
        static var defalutUrl = ""
        static var loginType: [LoginType]?
        static var anonymous: AnonymousConfigModel?

        private enum Keys {
            static let openNoTrace = "openNoTrace" // 无痕浏览的键值
            static let lastSyncTime = "lastSyncTime" // 同步时间的键值
            static let mode = "webMode"
        }

        /// 开启无痕浏览
        static var openNoTrace: Bool {
            get {
                return UserDefaults.standard.bool(forKey: Keys.openNoTrace)
            }
            set {
                UserDefaults.standard.set(newValue, forKey: Keys.openNoTrace)
            }
        }

        /// 导航模式，使用 UserDefaults 持久化
        static var mode: WebMode {
            get {
                let modeString = UserDefaults.standard.string(forKey: Keys.mode) ?? WebMode.web.rawValue
                return WebMode(rawValue: modeString) ?? .web
            }
            set {
                UserDefaults.standard.set(newValue.rawValue, forKey: Keys.mode)
            }
        }

        /// 记录同步时间
        static var lastSyncTime: Date? {
            get {
                return UserDefaults.standard.object(forKey: Keys.lastSyncTime) as? Date
            }
            set {
                UserDefaults.standard.set(newValue, forKey: Keys.lastSyncTime)
            }
        }
    }
}
