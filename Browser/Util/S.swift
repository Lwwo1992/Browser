//
//  Config.swift
//  Browser
//
//  Created by xyxy on 2024/10/11.
//

import Foundation

struct S {
    static var bookmark = HistoryModel()

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
        /// 导航页书签
        static let guideBookmark = "guideBookmarkTable"
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
        static var guideAnonymous: AnonymousConfigModel?

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

        static func lastSyncTimeAgo() -> String {
            guard let lastSyncTime = lastSyncTime else {
                return ""
            }
            let interval = Date().timeIntervalSince(lastSyncTime)

            if interval < 60 {
                return interval < 5 ? "刚刚" : "\(Int(interval))秒前"
            } else if interval < 3600 {
                return "\(Int(interval / 60))分钟前"
            } else if interval < 86400 {
                return "\(Int(interval / 3600))小时前"
            } else if interval < 2592000 {
                return "\(Int(interval / 86400))天前"
            } else {
                return "\(Int(interval / 2592000))个月前"
            }
        }
    }
}

extension S.Config {
    enum Environment {
        // 生产环境
        case production
        // 开发环境
        case development
        // 测试环境
        case testing

        static let current: Environment = {
            .development
        }()
    }

    static var apiURL: String {
        switch Environment.current {
        case .production:
            return "http://oa-api.saas-xy.com:89"
        case .development:
            return "http://merge-api.saas-xy.com:86"
        case .testing:
            return "http://merge-api.saas-xy.com:86"
        }
    }

    static var channelCode: String {
        switch Environment.current {
        case .production:
            return "browser"
        default:
            return "tomato"
        }
    }

    static var GRANT_CODE: String {
        switch Environment.current {
        case .production:
            return "kiueQf44NtLu"
        default:
            return "wkryw7roteux"
        }
    }
}

extension Notification.Name {
    static let jumpToLogin = Notification.Name("jumpToLogin")
}
