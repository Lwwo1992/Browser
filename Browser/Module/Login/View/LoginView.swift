//
//  LoginView.swift
//  Browser
//
//  Created by xyxy on 2024/10/10.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel

    var body: some View {
        VStack {
            Image(.tomatoCenter)
                .resizable()
                .scaledToFit()
                .padding(.top, 20)

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
            // 显示手机号码输入框
            if let phoneType = S.Config.loginType?.first(where: { $0.key == "mobile" }), phoneType.value == true {
                if viewModel.showMobileTextField {
                    HStack {
                        Text("+86")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        CustomTextField(text: $viewModel.mobile, placeholder: "手机号码", keyboardType: .numberPad)
                    }
                    .frame(height: 45)
                    .padding(.horizontal, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                } else {
                    Button {
                        viewModel.showMobileTextField.toggle()
                        viewModel.showMailboxTextField.toggle()
                    } label: {
                        Text("手机登录")
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

            Button {
                viewModel.nextButtonAction()
            } label: {
                Text("下一步")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .frame(width: 200)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(25)
            }

            // 判断是否展示 "或"
            if let accountType = S.Config.loginType?.first(where: { $0.key == "account" }), accountType.value == true,
               (S.Config.loginType?.contains(where: { $0.value == true })) ?? false {
                Text("或")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }

            if let accountType = S.Config.loginType?.first(where: { $0.key == "account" }), accountType.value == true {
                Button {
                    if viewModel.isAgree == false {
                        viewModel.showAgreeSheet = true
                    } else {
                        viewModel.isAgree = true
                        Util.topViewController().navigationController?.pushViewController(AccountLoginViewController(), animated: true)
                    }

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

            if let accountType = S.Config.loginType?.first(where: { $0.key == "mailbox" }), accountType.value == true {
                if viewModel.showMailboxTextField {
                    HStack {
                        CustomTextField(text: $viewModel.mailbox, placeholder: "邮箱")
                    }
                    .frame(height: 45)
                    .padding(.horizontal, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                } else {
                    Button {
                        viewModel.showMobileTextField.toggle()
                        viewModel.showMailboxTextField.toggle()
                    } label: {
                        Text("邮箱登录")
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
        }
        .padding(.horizontal, 25)
    }

    @ViewBuilder
    private func bottomView() -> some View {
        HStack {
            Button {
                viewModel.isAgree.toggle()
            } label: {
                Image(systemName: viewModel.isAgree ? "checkmark.square" : "square")
                    .foregroundColor(viewModel.isAgree ? .blue : .gray)
            }

            Text("我已阅读并同意:")
                .foregroundColor(.gray)

            agreementButton(title: "《服务协议》", requestData: 3, titleText: "服务协议")

            agreementButton(title: "《隐私协议》", requestData: 2, titleText: "隐私协议")
        }
        .font(.system(size: 13))
        .padding(.bottom, 5)
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
}

// #Preview {
//    LoginView()
// }
