//
//  VerificationCodeView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/12.
//

import SwiftUI

enum AccountType: Int {
    case account = 1, mobile, mailbox
}

enum VerificationCodeType {
    case login
    case replace
    case verify
}

struct VerificationCodeView: View {
    var accountNum: String = ""
    var accountType: AccountType = .mobile
    var verificationCodeType: VerificationCodeType = .login

    @State private var verifyCode = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("请输入验证码")
                .font(.system(size: 35, weight: .bold))

            Text("验证码已发送至 \(accountNum)")
                .font(.system(size: 14))

            HStack {
                Spacer()
                VStack {
                    VerifyCodeView { code in
                        verifyCode = code
                    }
                    .frame(height: 45)
                    .frame(width: 45 * 6 + 10 * 5)
                }
                Spacer()
            }

            Spacer()

            Button {
                if verifyCode.isEmpty {
                    HUD.showTipMessage("验证码不能为空")
                    return
                }
                verfy(of: verifyCode)
            } label: {
                Text("确定")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(25)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.bottom, 40)
        }
        .padding(.top, 30)
        .padding(.horizontal, 16)
    }

    private func verfy(of code: String) {
        let AecCode = BroAESCipher.encrypt(code) ?? ""
        switch verificationCodeType {
        case .login:
            login(AecCode)
        case .replace, .verify:
            checkValidCode(AecCode)
        }
    }

    private func login(_ code: String) {
        HUD.showLoading()
        APIProvider.shared.request(.login(credential: code, identifier: accountNum, type: accountType.rawValue), model: LoginModel.self) { result in
            HUD.hideNow()
            switch result {
            case let .success(model):

                model.logintype = "1"

                LoginManager.shared.info = model

                DBaseManager.share.updateToDb(table: S.Table.loginInfo,
                                              on: [
                                                  LoginModel.Properties.id,
                                                  LoginModel.Properties.token,
                                                  LoginModel.Properties.logintype,
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

    private func checkValidCode(_ code: String) {
        APIProvider.shared.request(.checkValidCode(credential: code, identifier: accountNum, type: accountType.rawValue)) { result in
            HUD.hideNow()
            switch result {
            case .success:
                if verificationCodeType == .replace {
                    updateEmailOrMobile(code)
                } else {
                    Util.topViewController().navigationController?.pushViewController(SetupPasswordViewController(), animated: true)
                }

            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }

    private func updateEmailOrMobile(_ code: String) {
        HUD.showLoading()
        APIProvider.shared.request(.updateEmailOrMobile(credential: code, identifier: accountNum, type: accountType.rawValue)) { result in
            HUD.hideNow()
            switch result {
            case .success:
                
                LoginManager.shared.fetchUserInfo()
                
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
}

struct VerifyCodeView: UIViewRepresentable {
    var onComplete: (String) -> Void

    func makeUIView(context: Context) -> MHVerifyCodeView {
        let verifyCodeView = MHVerifyCodeView()
        verifyCodeView.spacing = 10
        verifyCodeView.verifyCount = 6
        verifyCodeView.setCompleteHandler { result in
            onComplete(result)
        }
        return verifyCodeView
    }

    func updateUIView(_ uiView: MHVerifyCodeView, context: Context) {
    }
}

#Preview {
    VerificationCodeView()
}
