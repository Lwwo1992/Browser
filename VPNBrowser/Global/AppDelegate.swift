//
//  AppDelegate.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/8.
//

@_exported import Then
@_exported import WTool
@_exported import HandyJSON
@_exported import WCDBSwift

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
        DBaseManager.share.createTable(table: L.Table.configInfo, of: ConfigModel.self)
        DBaseManager.share.createTable(table: L.Table.loginInfo, of: LoginModel.self)
    }

    private func initConfig() {
        APIProvider.shared.request(.rankingPage(data: 1), model: ConfigByTypeModel.self) { result in
            switch result {
            case let .success(model):
                if let data = model.data {
                    DBaseManager.share.insertToDb(objects: [data], intoTable: L.Table.configInfo)

                    L.config.maxAppNum = data.maxAppNum ?? 5
                    L.config.defalutUrl = data.defalutUrl ?? ""
                    L.config.loginType = data.loginType
                }
            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
        
        if let model = DBaseManager.share.qureyFromDb(fromTable: L.Table.loginInfo, cls: LoginModel.self)?.first {
            LoginManager.shared.loginInfo = model
        }
    }
}
