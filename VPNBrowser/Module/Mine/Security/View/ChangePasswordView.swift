//
//  ChangePasswordView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/17.
//

import SwiftUI

struct PasswordEntryView: View {
    @Binding var password: String
    @State private var showPassword = false

    var placeholder: String

    var body: some View {
        HStack {
            CustomTextField(text: $password, placeholder: placeholder, isSecure: !showPassword)
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
    }
}

struct ChangePasswordView: View {
    @State private var password1: String = ""
    @State private var password2: String = ""
    @State private var password3: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text("当前账号: \(LoginManager.shared.info.account ?? "")")
                .font(.system(size: 14))

            PasswordEntryView(password: $password1, placeholder: "请输入密码")

            PasswordEntryView(password: $password2, placeholder: "请输入密码")

            PasswordEntryView(password: $password3, placeholder: "请输入密码")

            Button {
            } label: {
                Text("完成")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(25)
            }
            .padding(.top, 20)
            
            Button {
                Util.topViewController().popup.bottomSheet {
                    let view = ForgotPasswordBottomSheet(frame: CGRect(x: 0, y: 0, width: Util.deviceWidth, height: 240))
                    return view
                }
            } label: {
                Text("忘记密码?")
                    .font(.system(size: 16))
            }
            .padding(.top, 10)

            Spacer()
        }
        .padding(10)
        .padding(.horizontal, 16)
    }
}
