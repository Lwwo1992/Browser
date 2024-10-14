//
//  SecurityView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/8.
//

import SwiftUI
import WTool

struct SecurityView: View {
    enum SecurityOption: String, CaseIterable {
        case avatar = "头像"
        case nickname = "昵称"
        case phoneNumber = "手机号"
        case email = "邮箱"
        case account = "账号"
        case thirdPartyAccount = "三方账户"
        case logout = "退出登录"

        static var sections: [[SecurityOption]] {
            [
                [.avatar, .nickname],
                [.phoneNumber, .email, .account],
//                [.thirdPartyAccount],
                [.logout],
            ]
        }
    }

    var body: some View {
        OptionListView(
            sections: SecurityOption.sections,
            additionalTextProvider: { option in
                rightTitle(for: option)
            },
            rightViewProvider: { option in
                if option == .avatar {
                    return AnyView(
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    )
                }
                return nil
            },
            heightProvider: { option in
                if option == .avatar {
                    return 80
                }
                return nil
            },
            onTap: handleTap(for:)
        )
        .padding(.horizontal, 16)
    }

    private func rightTitle(for item: SecurityOption) -> String? {
        switch item {
        case .nickname:
            "用户昵称"
        case .phoneNumber:
            LoginManager.shared.loginInfo?.mobile.maskedAccount
        case .email:
            LoginManager.shared.loginInfo?.mailbox.maskedAccount
        case .account:
            LoginManager.shared.loginInfo?.account
        default:
            nil
        }
    }

    private func handleTap(for item: SecurityOption) {
        switch item {
        case .nickname:
            Util.topViewController().navigationController?.pushViewController(ChangeNicknameViewController(), animated: true)
        case .phoneNumber, .email:
            let vc = BindingViewController()
            vc.type = item == .phoneNumber ? .mobile : .mailbox
            Util.topViewController().navigationController?.pushViewController(vc, animated: true)
        case .logout:
            logout()
        default:
            break
        }
    }

    private func logout() {
        HUD.showLoading()
        APIProvider.shared.request(.logout) { result in
            HUD.hideNow()
            switch result {
            case .success:
                LoginManager.shared.loginInfo = nil
                DBaseManager.share.deleteFromDb(fromTable: S.Table.loginInfo)
                Util.topViewController().navigationController?.popToRootViewController(animated: true)
            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }
}

#Preview {
    SecurityView()
}
