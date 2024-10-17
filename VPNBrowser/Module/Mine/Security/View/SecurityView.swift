//
//  SecurityView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/8.
//
import AWSMobileClient
import AWSS3
import SDWebImageSwiftUI
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
                [.logout],
            ]
        }
    }

    @State private var selectedImage: UIImage?
    @State private var isShowingActionSheet = false
    private let imagePickerManager = ImagePicker()

    var body: some View {
        OptionListView(
            sections: SecurityOption.sections,
            additionalTextProvider: { option in
                rightTitle(for: option)
            },
            rightViewProvider: { option in
                if option == .avatar {
                    return AnyView(avatarView)
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
        .actionSheet(isPresented: $isShowingActionSheet) {
            ActionSheet(title: Text("选择头像"), message: nil, buttons: [
                .default(Text("相机")) {
                    presentImagePicker(sourceType: .camera)
                },
                .default(Text("相册")) {
                    presentImagePicker(sourceType: .photoLibrary)
                },
                .cancel(),
            ])
        }
    }

    private var avatarView: some View {
        Group {
            if LoginManager.shared.fetchUserModel().headPortrait.count > 0 {
                WebImage(url: URL(string: LoginManager.shared.fetchUserModel().headPortrait))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())

            } else {
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .foregroundColor(.gray)
                }
            }
        }
    }

    private func handleTap(for item: SecurityOption) {
        switch item {
        case .avatar:
            isShowingActionSheet = true

        case .nickname:
            Util.topViewController().navigationController?.pushViewController(ChangeNicknameViewController(), animated: true)
        case .phoneNumber:
            if LoginManager.shared.info.mobile.isEmpty {
                let vc = ReplaceBindingViewController()
                vc.acctype = .mobile
                Util.topViewController().navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = BindingViewController()
                vc.type = .mobile
                Util.topViewController().navigationController?.pushViewController(vc, animated: true)
            }
        case .email:
            if LoginManager.shared.info.mailbox.isEmpty {
                let vc = ReplaceBindingViewController()
                vc.acctype = .mailbox
                Util.topViewController().navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = BindingViewController()
                vc.type = .mailbox
                Util.topViewController().navigationController?.pushViewController(vc, animated: true)
            }
        case .logout:
            logout()
        case .account:
            let vc = AccountViewController()
            vc.title = item.rawValue
            Util.topViewController().navigationController?.pushViewController(vc, animated: true)
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
                let model = LoginModel()
                model.logintype = "0"
                model.token = "0"
                LoginManager.shared.info = model
                DBaseManager.share.updateToDb(table: S.Table.loginInfo,
                                              on: [LoginModel.Properties.logintype,
                                                   LoginModel.Properties.token,
                                              ],
                                              with: model)

                Util.topViewController().navigationController?.popToRootViewController(animated: true)
            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }

    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        imagePickerManager.pickImage(sourceType: sourceType, from: Util.topViewController()) { image, urlstring in
            if let image = image {
                selectedImage = image
                // 这里可以添加额外的处理，例如上传头像
                UpdateImageInfo(urlStr: urlstring ?? "")
            }
        }
    }

    private func UpdateImageInfo(urlStr: String) {
        APIProvider.shared.request(.uploadConfig, model: UpdateHeadInfo.self) { result in
            switch result {
            case let .success(response):

                // 处理响应
                let m = response

                let s3Client = S3ClientUtils(accessKey: m.accessKey, secretKey: m.secretKey, token: m.token, endpoint: m.endpoint)

                s3Client.uploadImageToS3(filePath: urlStr, model: m) { imgUrl, _ in

                    if let imgUrl, !imgUrl.isEmpty {
                        LoginManager.shared.info.headPortrait = imgUrl

                        updateUserInfo(imgUrl: imgUrl)
                    }
                }

            case let .failure(error):
                print("请求失败，错误：\(error)")
            }
        }
    }

    private func rightTitle(for item: SecurityOption) -> String? {
        switch item {
        case .nickname:
            return LoginManager.shared.fetchUserModel().name
        case .phoneNumber:
            return LoginManager.shared.fetchUserModel().mobile.maskedAccount
        case .email:
            return LoginManager.shared.fetchUserModel().mailbox.maskedAccount
        case .account:
            return LoginManager.shared.fetchUserModel().account
        default:
            return nil
        }
    }

    private func updateUserInfo(imgUrl: String) {
        HUD.showLoading()
        APIProvider.shared.request(.editUserInfo(headPortrait: imgUrl, name: "", id: LoginManager.shared.fetchUserModel().id)) {
            result in
            HUD.hideNow()
            switch result {
            case .success:

                LoginManager.shared.info.headPortrait = imgUrl

                DBaseManager.share.updateToDb(table: S.Table.loginInfo,
                                              on: [LoginModel.Properties.headPortrait],
                                              with: LoginManager.shared.info
                )

                Util.topViewController().navigationController?.popToRootViewController(animated: true)
                HUD.showTipMessage("修改成功")
            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }
}

#Preview {
    SecurityView()
}
