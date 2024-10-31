//
//  SetupPasswordView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/18.
//

import SwiftUI

struct SetupPasswordView: View {
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            PasswordEntryView(password: $newPassword, placeholder: "密码")

            PasswordEntryView(password: $confirmPassword, placeholder: "请确认密码")

            Button {
                request()
            } label: {
                Text("完成")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(25)
            }
            .padding(.top, 20)

            Spacer()
        }
        .padding(10)
        .padding(.horizontal, 16)
    }

    private func request() {
        if newPassword != confirmPassword {
            HUD.showTipMessage("两次密码不一致")
            return
        }

        if !Util.isValidPassword(newPassword) {
            return
        }

        HUD.showLoading()
        APIProvider.shared.request(.forgetPassword(password: EncryptUtil.encrypt(newPassword))) { result in
            switch result {
            case .success:
                HUD.showTipMessage("设置成功")

                LoginManager.shared.info = LoginModel()
                LoginManager.shared.userInfo = LoginModel()
                DBaseManager.share.deleteFromDb(fromTable: S.Table.loginInfo)

                Util.topViewController().navigationController?.popToRootViewController(animated: false)

            case let .failure(error):
                print("Request failed with error: \(error)")
            }

            HUD.hideNow()
        }
    }
}
