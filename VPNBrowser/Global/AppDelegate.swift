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

//
//        DBaseManager.share.deleteFromDb(fromTable: S.Table.loginInfo)
//        
//        let loginInfo: LoginModel =  LoginModel()
//        loginInfo.id = "1846399316753186818"
//        loginInfo.loginId = "1846399316753186818"
//        
////        DBaseManager.share.updateToDb(table: S.Table.loginInfo, on: [LoginModel.Properties.id,LoginModel.Properties.loginId], with: loginInfo)
//        LoginManager.shared.saveLoginInfo(loginInfo)
        
        
        return true
    }
}

extension AppDelegate {
    private func confing() {
        initTable()
        
        
        initConfig()

        Util.createFolderIfNotExists(S.Files.imageURL)
    }

    private func initTable() {
        DBaseManager.share.createTable(table: S.Table.configInfo, of: ConfigModel.self)
        DBaseManager.share.createTable(table: S.Table.loginInfo, of: LoginModel.self)
        DBaseManager.share.createTable(table: S.Table.searchHistory, of: HistoryModel.self)
        DBaseManager.share.createTable(table: S.Table.browseHistory, of: HistoryModel.self)
        DBaseManager.share.createTable(table: S.Table.collect, of: HistoryModel.self)
        DBaseManager.share.createTable(table: S.Table.bookmark, of: HistoryModel.self)
    }

    private func initConfig() {
         
        if S.Config.isLogin{
 
            fetchConfigByType()
            fetchAnonymousConfig()
             
        }else{
            
            APIProvider.shared.request(.generateVisitorToken, progress: { _ in
                
            }) { result in
                switch result {
                case let .success(response):
                    if let responseString = String(data: response.data, encoding: .utf8) {
                        print("Response: \(responseString)") // 打印响应内容，方便调试
                    }
                    
                    do {
                        if let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: Any],
                           let data = json["data"] as? [String: Any],
                           let token = data["token"] as? String , let userId = data["id"] as? String {
 
                            LoginManager.shared.loginInfo.vistoken = token //单例存储
                            
                            let info = LoginManager.shared.fetchUserModel()
                            info.id = userId
                            info.logintype = "0"
                            
//                            DBaseManager.share.deleteFromDb(fromTable: S.Table.loginInfo)
//                            LoginManager.shared.saveLoginInfo(info)
                            
                            DBaseManager.share.updateToDb(table: S.Table.loginInfo, on: [LoginModel.Properties.id,LoginModel.Properties.logintype], with: info)
                            
                            
                            
                            // 继续执行其他接口请求
                            self.fetchConfigByType()
                            self.fetchAnonymousConfig()
                            //MineViewModel().fetchdata()
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

    private func fetchConfigByType() {
        
        APIProvider.shared.request(.getConfigByType(data: 1), model: ConfigByTypeModel.self) { result in
            switch result {
            case let .success(model):
                if let data = model.data {
                    DBaseManager.share.insertToDb(objects: [data], intoTable: S.Table.configInfo)

                    S.Config.maxAppNum = data.maxAppNum ?? 5
                    S.Config.defalutUrl = data.defalutUrl ?? ""
                    S.Config.loginType = data.loginType
                }
            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }

    private func fetchAnonymousConfig() {
        APIProvider.shared.request(.anonymousConfig, model: AnonymousConfigModel.self) { result in
            switch result {
            case let .success(model):
                S.Config.anonymous = model
            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }
}
