//
//  ChangePasswordView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/17.
//

import SwiftUI

struct ChangePasswordView: View {
    @State private var oldPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var showingActionSheet = false

    var body: some View {
        VStack(alignment: .leading) {
            Text("当前账号: \(LoginManager.shared.info.account ?? "")")
                .font(.system(size: 14))

            PasswordEntryView(password: $oldPassword, placeholder: "旧密码")

            PasswordEntryView(password: $newPassword, placeholder: "密码")

            PasswordEntryView(password: $confirmPassword, placeholder: "确认密码")

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

            Text("密码必须是8-16位英文字母、数字、字符、组合(不能是纯数字)")
                .font(.system(size: 14))
                .opacity(0.5)
                .padding(.top, 10)

            Button {
                showingActionSheet.toggle()
            } label: {
                Text("忘记密码?")
                    .font(.system(size: 16))
            }
            .padding(.top, 10)
            .actionSheet(isPresented: $showingActionSheet) {
                let mobile = LoginManager.shared.info.mobile
                let mailbox = LoginManager.shared.info.mailbox

                var buttons: [ActionSheet.Button] = []

                if !mailbox.isEmpty {
                    buttons.append(.default(Text("邮箱验证")
                            .foregroundColor(.blue)
                            .font(.title2)
                    ) {
                        sendEmailCode()
                    })
                }

                if !mobile.isEmpty {
                    buttons.append(.default(Text("手机号验证")
                            .foregroundColor(.green)
                            .font(.title2)
                    ) {
                        sendSmsode()
                    })
                }

                buttons.append(.cancel(Text("取消")
                        .foregroundColor(.red)
                        .font(.body)
                ))

                return ActionSheet(title: Text("获取验证码"), message: nil, buttons: buttons)
            }

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
        APIProvider.shared.request(.updatePassword(new: EncryptUtil.encrypt(newPassword), old: EncryptUtil.encrypt(oldPassword))) { result in
            HUD.hideNow()
            switch result {
            case .success:
                HUD.showTipMessage("设置成功")
                if let navigationController = Util.topViewController().navigationController {
                    if let securityVC = navigationController.viewControllers.first(where: { $0 is SecurityViewController }) {
                        navigationController.popToViewController(securityVC, animated: true)
                    }
                }
            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }

    private func sendSmsode() {
        HUD.showLoading()
        APIProvider.shared.request(.sendSmsCode(mobile: LoginManager.shared.info.mobile, nation: "+86")) { result in
            HUD.hideNow()
            switch result {
            case .success:
                let vc = VerificationCodeViewController()
                vc.accountNum = LoginManager.shared.info.mobile
                vc.accountType = .mobile
                vc.verificationCodeType = .verify
                Util.topViewController().navigationController?.pushViewController(vc, animated: true)
            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }

    private func sendEmailCode() {
        HUD.showLoading()
        APIProvider.shared.request(.sendEmailCode(mailbox: LoginManager.shared.info.mailbox)) { result in
            HUD.hideNow()
            switch result {
            case .success:
                let vc = VerificationCodeViewController()
                vc.accountNum = LoginManager.shared.info.mailbox
                vc.accountType = .mailbox
                vc.verificationCodeType = .verify
                Util.topViewController().navigationController?.pushViewController(vc, animated: true)
            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }
}

struct PasswordEntryView: View {
    @Binding var password: String
    @State private var showPassword = false

    var placeholder: String

    var body: some View {
        HStack {
            CustomTextField(text: $password, placeholder: placeholder, isSecure: !showPassword)

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
    }
}
