//
//  LoginView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/10.
//

import SwiftUI

struct LoginView: View {
    @State private var isAgree = false
    @State private var mobile: String = ""
    @State private var mailbox: String = ""

    var body: some View {
        VStack {
            Image(.tomatoCenter)
                .resizable()
                .scaledToFit()
                .padding(.top, 30)

            Spacer()

            LoginTypeView()

            Spacer()

            bottomView()
        }
        .padding(.horizontal, 16)
        .background(Color.white)
    }

    @ViewBuilder
    private func LoginTypeView() -> some View {
        VStack(spacing: 20) {
            if mailbox.isEmpty {
                // 显示手机号码输入框
                if let phoneType = S.Config.loginType?.first(where: { $0.key == "mobile" }), phoneType.value == true {
                    HStack {
                        Text("+86")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        CustomTextField(text: $mobile, placeholder: "手机号码", keyboardType: .numberPad)
                    }
                    .frame(height: 45)
                    .padding(.horizontal, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                    .transition(.move(edge: .leading).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.3), value: mobile)
                }
            }

            if mobile.isEmpty {
                // 显示邮箱输入框
                if let emailType = S.Config.loginType?.first(where: { $0.key == "mailbox" }), emailType.value == true {
                    HStack {
                        CustomTextField(text: $mailbox, placeholder: "邮箱")
                    }
                    .frame(height: 45)
                    .padding(.horizontal, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.3), value: mailbox)
                }
            }

            // 判断是否展示 "或"
            if let accountType = S.Config.loginType?.first(where: { $0.key == "account" }), accountType.value == true,
               (S.Config.loginType?.contains(where: { $0.value == true })) ?? false {
                Button {
                    nextButtonAction()
                } label: {
                    Text("下一步")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .frame(width: 200)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(25)
                }

                Text("或")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }

            if let accountType = S.Config.loginType?.first(where: { $0.key == "account" }), accountType.value == true {
                Button {
                    if isAgree == false {
                        HUD.showTipMessage("未阅读《服务协议》、《隐私政策》")
                        return
                    }
                    Util.topViewController().navigationController?.pushViewController(AccountLoginViewController(), animated: true)
                } label: {
                    Text("账户登录")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                }
            }
        }
        .padding(.horizontal, 25)
    }

    @ViewBuilder
    private func bottomView() -> some View {
        HStack {
            Button {
                isAgree.toggle()
            } label: {
                Image(systemName: isAgree ? "checkmark.square" : "square")
                    .foregroundColor(isAgree ? .blue : .gray)
            }

            Text("我已阅读并同意:")
                .foregroundColor(.gray)

            agreementButton(title: "《服务协议》", requestData: 3, titleText: "服务协议")

            agreementButton(title: "《隐私协议》", requestData: 2, titleText: "隐私协议")
        }
        .font(.system(size: 12))
    }

    private func agreementButton(title: String, requestData: Int, titleText: String) -> some View {
        Button {
            fetchAgreementContent(requestData: requestData, titleText: titleText)
        } label: {
            Text(title)
        }
    }
}

extension LoginView {
    private func fetchAgreementContent(requestData: Int, titleText: String) {
        HUD.showLoading()
        APIProvider.shared.request(.getConfigByType(data: requestData), model: ConfigByTypeModel.self) { result in
            HUD.hideNow()
            switch result {
            case let .success(model):
                if let content = model.content {
                    let vc = TextDisplayViewController()
                    vc.title = titleText
                    vc.content = content
                    Util.topViewController().navigationController?.pushViewController(vc, animated: true)
                }
            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }

    private func nextButtonAction() {
        if isAgree == false {
            HUD.showTipMessage("未阅读《服务协议》、《隐私政策》")
            return
        }

        if !mobile.isEmpty {
            if Util.isValidPhoneNumber(mobile) {
                HUD.showTipMessage("手机号码格式错误")
                return
            }
            sendSmsode()
        }

        if !mailbox.isEmpty {
            if Util.isValidEmail(mailbox) {
                HUD.showTipMessage("邮箱格式错误")
                return
            }

            sendEmailCode()
        }
    }

    private func sendSmsode() {
        HUD.showLoading()
        APIProvider.shared.request(.sendSmsCode(mobile: mobile, nation: "+86")) { result in
            HUD.hideNow()
            switch result {
            case .success:
                let vc = VerificationCodeViewController()
                vc.accountNum = "" + mobile
                vc.accountType = .mobile
                Util.topViewController().navigationController?.pushViewController(vc, animated: true)
            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }

    private func sendEmailCode() {
        HUD.showLoading()
        APIProvider.shared.request(.sendEmailCode(mailbox: mailbox)) { result in
            HUD.hideNow()
            switch result {
            case .success:
                let vc = VerificationCodeViewController()
                vc.accountNum = mailbox
                vc.accountType = .mailbox
                Util.topViewController().navigationController?.pushViewController(vc, animated: true)
            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }
}

// #Preview {
//    LoginView()
// }
