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

import IQKeyboardManagerSwift
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        confing()

        HUD.showLoading()
        netWorkConfig { [weak self] in
            guard let self else { return }
            HUD.hideNow()
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.backgroundColor = .white
            window?.makeKeyAndVisible()
            window?.rootViewController = TabBarController()
        }

        return true
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
        DBaseManager.share.createTable(table: S.Table.download, of: DownloadModel.self)
    }

    func netWorkConfig(completion: (() -> Void)? = nil) {
        LoginManager.shared.fetchUserInfo()

        if LoginManager.shared.info.userType == .user {
            fetchConfigByType {
                self.fetchAnonymousConfig {
                    completion?()
                }
            }
        } else {
            APIProvider.shared.request(.generateVisitorToken, progress: { _ in

            }) { [weak self] result in
                guard let self else { return }
                switch result {
                case let .success(response):
                    if let responseString = String(data: response.data, encoding: .utf8) {
                        print("Response: \(responseString)")
                    }

                    do {
                        if let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: Any],
                           let data = json["data"] as? [String: Any],
                           let token = data["token"] as? String,
                           let userId = data["id"] as? String {
                            let model = LoginModel()
                            model.id = userId
                            model.userType = .visitor
                            model.vistoken = token

                            LoginManager.shared.info = model

                            if let array = DBaseManager.share.qureyFromDb(fromTable: S.Table.loginInfo, cls: LoginModel.self), !array.isEmpty {
                                DBaseManager.share.updateToDb(table: S.Table.loginInfo,
                                                              on: [
                                                                  LoginModel.Properties.id,
                                                                  LoginModel.Properties.vistoken,
                                                                  LoginModel.Properties.userTypeV,
                                                              ],
                                                              with: model)
                            } else {
                                DBaseManager.share.insertToDb(objects: [model], intoTable: S.Table.loginInfo)
                            }

                            // 配置获取成功
                            self.fetchConfigByType {
                                self.fetchAnonymousConfig {
                                    completion?() // 执行回调
                                }
                            }

                        } else {
                            print("无法提取 token")
                        }
                    } catch {
                        HUD.showTipMessage(error.localizedDescription)
                        print("JSON 解析失败: \(error)")
                    }

                case let .failure(error):
                    print("请求失败: \(error)")
                }
            }
        }
    }

    private func fetchConfigByType(completion: (() -> Void)? = nil) {
        APIProvider.shared.request(.getConfigByType(data: 1), model: ConfigByTypeModel.self) { result in
            switch result {
            case let .success(model):
                if let data = model.data {
                    DBaseManager.share.insertToDb(objects: [data], intoTable: S.Table.configInfo)

                    S.Config.maxAppNum = data.maxAppNum ?? 5
                    S.Config.defalutUrl = data.defalutUrl ?? ""
                    S.Config.loginType = data.loginType
                }
                completion?()

            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }

    private func fetchAnonymousConfig(completion: (() -> Void)? = nil) {
        APIProvider.shared.request(.anonymousConfig, model: AnonymousConfigModel.self) { result in
            switch result {
            case let .success(model):
                S.Config.anonymous = model
                completion?()

            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }
}
