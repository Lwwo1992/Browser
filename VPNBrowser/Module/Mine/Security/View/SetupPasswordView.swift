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

        if !Util.isPasswordValid(newPassword) {
            return
        }

        HUD.showLoading()
        APIProvider.shared.request(.forgetPassword(password: newPassword)) { result in
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
}

#Preview {
    SetupPasswordView()
}
