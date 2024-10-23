//
//  AccountLoginView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/11.
//

import SwiftUI

struct AccountLoginView: View {
    @State private var account: String = ""
    @State private var password: String = ""
    @State private var showPassword = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("账户密码登录")
                .font(.system(size: 35, weight: .bold))

            CustomTextField(text: $account, placeholder: "请输入账号/手机号/邮箱")
                .frame(height: 45)
                .padding(.horizontal, 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
                .padding(.top, 30)

            HStack {
                CustomTextField(text: $password, placeholder: "请输入密码", isSecure: !showPassword)
                    .padding(10)

                Button {
                    showPassword.toggle()
                } label: {
                    Image(systemName: showPassword ? "eye.fill" : "eye.slash.fill")
                        .foregroundColor(.gray.opacity(0.5))
                }
            }
            .frame(height: 45)
            .padding(.horizontal, 15)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
            .padding(.top, 10)

            Spacer()

            Button {
                login()
            } label: {
                Text("登录")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(25)
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 16)
        .padding(.top, 30)
    }

    private func login() {
        if password.isEmpty && account.isEmpty {
            HUD.showTipMessage("账号密码不能为空")
            return
        }

        HUD.showLoading()
        APIProvider.shared.request(.login(credential: password, identifier: account, type: AccountType.account.rawValue), model: LoginModel.self) { result in
            HUD.hideNow()
            switch result {
            case let .success(model):
                model.userType = .user
                
                LoginManager.shared.info = model

                DBaseManager.share.updateToDb(table: S.Table.loginInfo,
                                              on: [
                                                  LoginModel.Properties.id,
                                                  LoginModel.Properties.token,
                                                  LoginModel.Properties.userTypeV,
                                              ],
                                              with: model)

                LoginManager.shared.fetchUserInfo(model.id)

                Util.topViewController().navigationController?.popToRootViewController(animated: true)

                HUD.showTipMessage("登录成功")

            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }
}

#Preview {
    AccountLoginView()
}
