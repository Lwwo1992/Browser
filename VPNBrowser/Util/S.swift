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


