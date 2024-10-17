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

    func fetchUserInfo(_ userID: String = LoginManager.shared.info.id) {
        APIProvider.shared.request(.browserAccount(userId: userID), model: LoginModel.self) { [weak self] result in
            guard let self else { return }
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
                if let info = DBaseManager.share.qureyFromDb(fromTable: S.Table.loginInfo, cls: LoginModel.self)?.first {
                    self.info = info
                }

            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }
}
