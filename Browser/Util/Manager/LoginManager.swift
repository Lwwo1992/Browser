//
//  LoginManager.swift
//  Browser
//
//  Created by xyxy on 2024/10/12.
//

class LoginManager: ObservableObject {
    @Published var info = LoginModel()
    @Published var userInfo = LoginModel()

    static let shared = LoginManager()

    private init() {
        if let model = DBaseManager.share.qureyFromDb(fromTable: S.Table.loginInfo, cls: LoginModel.self)?.first {
            info = model
        }
    }

    func fetchUserInfo(_ userID: String = LoginManager.shared.info.id) {
        let requestType: APITarget = (LoginManager.shared.info.userType != .visitor && !LoginManager.shared.info.token.isEmpty) ? .browserAccount(userId: userID) : .visitorAccess(id: userID)

        APIProvider.shared.request(requestType, model: LoginModel.self) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(model):
                self.userInfo = model
                self.updateUserType(for: model)
                self.updateUserInfoInDatabase(with: model)

                if let info = DBaseManager.share.qureyFromDb(fromTable: S.Table.loginInfo, cls: LoginModel.self)?.first {
                    self.info = info
                }

            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }

    private func updateUserType(for model: LoginModel) {
        if let vipCardVO = model.vipCardVO, !vipCardVO.isEmpty {
            model.userType = .vipUser
        } else if LoginManager.shared.info.userType == .user {
            model.userType = .user
        } else {
            model.userType = .visitor
        }
    }

    private func updateUserInfoInDatabase(with model: LoginModel) {
        DBaseManager.share.updateToDb(table: S.Table.loginInfo,
                                      on: [
                                          LoginModel.Properties.name,
                                          LoginModel.Properties.account,
                                          LoginModel.Properties.mailbox,
                                          LoginModel.Properties.mobile,
                                          LoginModel.Properties.createTime,
                                          LoginModel.Properties.userTypeV,
                                          LoginModel.Properties.visitor
                                      ],
                                      with: model)
    }
}
