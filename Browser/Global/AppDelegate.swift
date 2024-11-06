//
//  AppDelegate.swift
//  Browser
//
//  Created by xyxy on 2024/10/8.
//

@_exported import HandyJSON
@_exported import Then
@_exported import WCDBSwift
@_exported import WTool

import IQKeyboardManagerSwift
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        confing()

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()
        window?.rootViewController = TabBarController()

        return true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        /// 生成 游客token
        /// 为分享活动生效
        if LoginManager.shared.info.userType == .visitor || LoginManager.shared.info.token.isEmpty {
            APIProvider.shared.request(.generateVisitorToken) { _ in }
        }
    }
}

extension AppDelegate {
    private func confing() {
        initTable()

        if #available(iOS 13.0, *) {
            self.window?.overrideUserInterfaceStyle = UIUserInterfaceStyle.light
        }
        IQKeyboardManager.shared.enable = true

        Util.createFolderIfNotExists(S.Files.imageURL)
        Util.createFolderIfNotExists(S.Files.downloads)
    }

    private func initTable() {
        DBaseManager.share.createTable(table: S.Table.configInfo, of: ConfigModel.self)
        DBaseManager.share.createTable(table: S.Table.loginInfo, of: LoginModel.self)
        DBaseManager.share.createTable(table: S.Table.searchHistory, of: HistoryModel.self)
        DBaseManager.share.createTable(table: S.Table.browseHistory, of: HistoryModel.self)
        DBaseManager.share.createTable(table: S.Table.collect, of: HistoryModel.self)
        DBaseManager.share.createTable(table: S.Table.folder, of: HistoryModel.self)
        DBaseManager.share.createTable(table: S.Table.bookmark, of: HistoryModel.self)
        DBaseManager.share.createTable(table: S.Table.guideBookmark, of: HistoryModel.self)
        DBaseManager.share.createTable(table: S.Table.download, of: DownloadModel.self)
    }
}
