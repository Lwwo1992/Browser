//
//  BindingView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/12.
//

import SwiftUI

struct BindingView: View {
    var type: AccountType = .mobile
    @State private var showPassword = false

    var body: some View {
        VStack {
            HStack {
                Text(getBindingText(for: type))
                    .font(.system(size: 16))
                    .opacity(0.5)

                Button {
                    showPassword.toggle()
                } label: {
                    Image(systemName: showPassword ? "eye.fill" : "eye.slash.fill")
                        .foregroundColor(.gray.opacity(0.5))
                }
            }
            .padding(.top, 60)

            Spacer()

            Button {
                let v = ReplaceBindingViewController()
                v.acctype = type
                Util.topViewController().navigationController?.pushViewController(v, animated: true)
            } label: {
                Text("更换")
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

    private func getBindingText(for type: AccountType) -> String {
        let accountInfo = type == .mobile ? LoginManager.shared.info.mobile : LoginManager.shared.info.mailbox
        let accountTypeText = type == .mobile ? "手机号" : "邮箱"

        let displayAccountInfo = showPassword ? accountInfo : (accountInfo.maskedAccount)

        return "已绑定\(accountTypeText): \(displayAccountInfo)"
    }
}

#Preview {
    BindingView()
}
