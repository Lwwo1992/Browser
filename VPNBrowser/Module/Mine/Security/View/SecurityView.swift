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

    @ObservedObject var viewModel = LoginManager.shared
    @State private var selectedImage: UIImage?
    @State private var isShowingActionSheet = false
    @State private var showingAlert = false
    private let imagePickerManager = ImagePicker()

    var body: some View {
        VStack {
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

            Spacer()

            Button {
                showingAlert.toggle()
            } label: {
                Text("注销账号")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .opacity(0.5)
            }
            .padding(.bottom, 20)
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("提示"),
                    message: Text("注销账号,将无法恢复"),
                    primaryButton: .destructive(Text("删除")) {
                        cancelAccount()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
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
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            } else {
                WebImage(url: URL(string: viewModel.info.headPortrait)) { Image in
                    Image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } placeholder: {
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
                fetchVisitorToken()
            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }

    private func fetchVisitorToken() {
        APIProvider.shared.request(.generateVisitorToken, progress: { _ in

        }) { result in
            switch result {
            case let .success(response):
                if let responseString = String(data: response.data, encoding: .utf8) {
                    print("Response: \(responseString)")
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: Any],
                       let data = json["data"] as? [String: Any],
                       let token = data["token"] as? String,
                       let userId = data["id"] as? String {
                        let model = LoginModel()
                        model.id = userId
                        model.logintype = "0"
                        model.vistoken = token

                        DBaseManager.share.updateToDb(table: S.Table.loginInfo,
                                                      on: [
                                                          LoginModel.Properties.id,
                                                          LoginModel.Properties.vistoken,
                                                          LoginModel.Properties.logintype,
                                                      ],
                                                      with: model)

                        LoginManager.shared.info = model

                        Util.topViewController().navigationController?.popToRootViewController(animated: true)

                    } else {
                        print("无法提取 token")
                    }
                } catch {
                    HUD.showTipMessage(error.localizedDescription)
                    print("JSON 解析失败: \(error)")
                }

            case let .failure(error):
                print("请求失败: \(error)")
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
            return viewModel.info.name
        case .phoneNumber:
            return viewModel.info.mobile.maskedAccount
        case .email:
            return viewModel.info.mailbox.maskedAccount
        case .account:
            return viewModel.info.account
        default:
            return nil
        }
    }

    private func updateUserInfo(imgUrl: String) {
        HUD.showLoading()
        APIProvider.shared.request(.editUserInfo(headPortrait: imgUrl, name: "", id: LoginManager.shared.info.id)) {
            result in
            HUD.hideNow()
            switch result {
            case .success:

                HUD.showTipMessage("修改成功")

                let model = LoginModel()
                model.headPortrait = imgUrl

                DBaseManager.share.updateToDb(table: S.Table.loginInfo,
                                              on: [LoginModel.Properties.headPortrait],
                                              with: model
                )

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

    /// 注销账号
    private func cancelAccount() {
        HUD.showLoading()
        APIProvider.shared.request(.accountDelete) { result in
            HUD.hideNow()
            switch result {
            case .success:
                fetchVisitorToken()
            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }
}

#Preview {
    SecurityView()
}
