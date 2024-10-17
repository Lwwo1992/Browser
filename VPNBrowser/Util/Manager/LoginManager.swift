//
//  LoginManager.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/12.
//
 
class LoginManager: ObservableObject {
    @Published var loginInfo: LoginModel =  LoginModel()

    static let shared = LoginManager()
    
    private init() {
        // 尝试从数据库中加载登录信息
        if let model = DBaseManager.share.qureyFromDb(fromTable: S.Table.loginInfo, cls: LoginModel.self)?.first {
            self.loginInfo = model
        }
    }
  

    // 保存登录信息
    func saveLoginInfo(_ info: LoginModel) {
//        self.loginInfo = info
        // 插入到数据库
        DBaseManager.share.insertToDb(objects: [info], intoTable: S.Table.loginInfo)
        
          DispatchQueue.main.async {
              self.loginInfo = info
          }
    }
    
     
    
    func fetchUserModel() -> LoginModel {
        
//        let v1 = DBaseManager.share.qureyFromDb(fromTable: S.Table.loginInfo, cls: LoginModel.self)
        
        
        if let model = DBaseManager.share.qureyFromDb(fromTable: S.Table.loginInfo, cls: LoginModel.self)?.first {
            DispatchQueue.main.async {
                self.loginInfo = model
            }
            return model
        } else {
            return LoginModel()
        }
    }
    
}
