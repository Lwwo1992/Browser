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

struct VerificationCodeView: View {
    var accountNum: String = ""
    var accountType: AccountType = .mobile

    @State private var verifyCode = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("账户密码登录")
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

            Button {
                if verifyCode.isEmpty {
                    HUD.showTipMessage("验证码不能为空")
                    return
                }
                verfy(of: verifyCode)
            } label: {
                Text("登录")
                    .foregroundColor(.white)
                    .frame(width: 260)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(25)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.top, 40)

            Spacer()
        }
        .padding(.top, 30)
        .padding(.horizontal, 16)
    }

    private func verfy(of code: String) {
        HUD.showLoading()
        APIProvider.shared.request(.login(credential: code, identifier: accountNum, type: accountType.rawValue), model: LoginModel.self) { result in
            HUD.hideNow()
            switch result {
            case let .success(model):

                LoginManager.shared.loginInfo = model

                DBaseManager.share.insertToDb(objects: [model], intoTable: L.Table.loginInfo)

                HUD.showTipMessage("登录成功")
                Util.topViewController().navigationController?.popToRootViewController(animated: true)

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
