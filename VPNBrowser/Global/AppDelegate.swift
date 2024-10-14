//
//  AppDelegate.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/8.
//

@_exported import HandyJSON
@_exported import Then
@_exported import WCDBSwift
@_exported import WTool

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
}

extension AppDelegate {
    private func confing() {
        initTable()
        initConfig()
    }

    private func initTable() {
        DBaseManager.share.createTable(table: S.Table.configInfo, of: ConfigModel.self)
        DBaseManager.share.createTable(table: S.Table.loginInfo, of: LoginModel.self)
        DBaseManager.share.createTable(table: S.Table.searchHistory, of: HistoryModel.self)
        DBaseManager.share.createTable(table: S.Table.browseHistory, of: HistoryModel.self)
    }

    private func initConfig() {
        APIProvider.shared.request(.getConfigByType(data: 1), model: ConfigByTypeModel.self) { result in
            switch result {
            case let .success(model):
                if let data = model.data {
                    DBaseManager.share.insertToDb(objects: [data], intoTable: S.Table.configInfo)

                    S.config.maxAppNum = data.maxAppNum ?? 5
                    S.config.defalutUrl = data.defalutUrl ?? ""
                    S.config.loginType = data.loginType
                }
            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }

        /// 查询上传配置
        APIProvider.shared.request(.anonymousConfig, model: AnonymousConfigModel.self) { result in
            switch result {
            case let .success(model):
                S.config.anonymous = model
            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }

        if let model = DBaseManager.share.qureyFromDb(fromTable: S.Table.loginInfo, cls: LoginModel.self)?.first {
            LoginManager.shared.loginInfo = model
        }
    }
}
