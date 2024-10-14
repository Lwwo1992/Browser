//
//  ReplaceBindingView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/14.
//

import SwiftUI

struct ReplaceBindingView: View {
    @State private var mailbox: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text("一个邮箱只能绑定一个账号,更换后可使用新邮箱登录此账号.对于已绑定其他账号的邮箱,本次操作后将与原账号解绑.")
                .font(.system(size: 14))
                .opacity(0.5)
                .padding(.top, 40)

            Text("邮箱地址")
                .font(.system(size: 14))
                .opacity(0.5)
                .padding(.top, 40)
            HStack {
                CustomTextField(text: $mailbox, placeholder: "请输入邮箱地址")
            }
            .frame(height: 45)
            .padding(.horizontal, 10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )

            Spacer()

            Button {
                nextButtonAction()
            } label: {
                Text("下一步")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(25)
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 16)
    }

    private func nextButtonAction() {
        if Util.isValidEmail(mailbox) && !mailbox.isEmpty {
            HUD.showTipMessage("格式错误")
            return
        }

        HUD.showLoading()
        APIProvider.shared.request(.sendEmailCode(mailbox: mailbox)) { result in
            HUD.hideNow()
            switch result {
            case .success:
                let vc = VerificationCodeViewController()
                vc.accountNum = mailbox
                vc.accountType = .mailbox
                vc.verificationCodeType = .replace
                Util.topViewController().navigationController?.pushViewController(vc, animated: true)
            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }
}

#Preview {
    ReplaceBindingView()
}
