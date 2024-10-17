//
//  LoginManager.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/12.
//

class LoginManager: ObservableObject {
    @Published var info = LoginModel()

    static let shared = LoginManager()

    private init() {
        if let model = DBaseManager.share.qureyFromDb(fromTable: S.Table.loginInfo, cls: LoginModel.self)?.first {
            info = model
        }
    }

    func fetchUserModel() -> LoginModel {
        if let model = DBaseManager.share.qureyFromDb(fromTable: S.Table.loginInfo, cls: LoginModel.self)?.first {
            DispatchQueue.main.async {
                self.info = model
            }
            return model
        } else {
            return LoginModel()
        }
    }

    static func fetchUserInfo() {
        if LoginManager.shared.info.logintype == "1" {
            APIProvider.shared.request(.browserAccount(userId: LoginManager.shared.info.id), model: LoginModel.self) { result in
                switch result {
                case let .success(model):
                    DBaseManager.share.updateToDb(table: S.Table.loginInfo,
                                                  on: [
                                                      LoginModel.Properties.name,
                                                      LoginModel.Properties.account,
                                                      LoginModel.Properties.mailbox,
                                                      LoginModel.Properties.mobile,
                                                      LoginModel.Properties.createTime,
                                                  ],
                                                  with: model)

                case let .failure(error):
                    print("Request failed with error: \(error)")
                }
            }
        }
    }
}
