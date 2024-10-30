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
    @State private var isShowingActionSheet = false
    @State private var showingAlert = false
    @State private var showingLoginAlert = false
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
            .alert(isPresented: $showingLoginAlert) {
                Alert(
                    title: Text("退出登录"),
                    message: Text("退出登录后、书签、收藏无法实现同步,存在丢失风险,确认要退出嘛?"),
                    primaryButton: .destructive(Text("确认退出")) {
                        logout()
                    },
                    secondaryButton: .cancel()
                )
            }

            Spacer()

            Button {
                showingAlert = true
            } label: {
                Text("注销账号")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .opacity(0.5)
            }
            .padding(.bottom, 20)
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("注销账户"),
                    message: Text("注销账户后、书签、收藏的资料将全部删除,确认要注销账户?"),
                    primaryButton: .destructive(Text("确认注销")) {
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

    private func handleTap(for item: SecurityOption) {
        switch item {
        case .avatar:
            isShowingActionSheet = true

        case .nickname:
            Util.topViewController().navigationController?.pushViewController(ChangeNicknameViewController(), animated: true)
        case .phoneNumber:
            if viewModel.info.mobile.isEmpty {
                let vc = ReplaceBindingViewController()
                vc.acctype = .mobile
                Util.topViewController().navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = BindingViewController()
                vc.type = .mobile
                Util.topViewController().navigationController?.pushViewController(vc, animated: true)
            }
        case .email:
            if viewModel.info.mailbox.isEmpty {
                let vc = ReplaceBindingViewController()
                vc.acctype = .mailbox
                Util.topViewController().navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = BindingViewController()
                vc.type = .mailbox
                Util.topViewController().navigationController?.pushViewController(vc, animated: true)
            }
        case .logout:
            showingLoginAlert = true
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
        /// 清空数据
        LoginManager.shared.info = LoginModel()
        LoginManager.shared.userInfo = LoginModel()
        DBaseManager.share.deleteFromDb(fromTable: S.Table.loginInfo)

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
                        model.userType = .visitor
                        model.vistoken = token

                        DBaseManager.share.insertToDb(objects: [model], intoTable: S.Table.loginInfo)

                        if let array = DBaseManager.share.qureyFromDb(fromTable: S.Table.loginInfo, cls: LoginModel.self), let model = array.first {
                            LoginManager.shared.info = model
                        }

                        LoginManager.shared.fetchUserInfo()

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
                HUD.showTipMessage(error.localizedDescription)
            }
        }
    }

    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        imagePickerManager.pickImage(sourceType: sourceType, from: Util.topViewController()) { image, _ in
            guard let selectedImage = image else {
                print("No image selected")
                return
            }

            // 调用保存图片方法并生成本地 URL
            if let localURL = saveImageToLocalDirectory(image: selectedImage) {
                // 使用生成的 URL 调用 UpdateImageInfo
                UpdateImageInfo(urlStr: localURL.path)
            } else {
                print("Failed to save image")
            }
        }
    }

    /// 将 UIImage 保存到本地目录并返回文件路径
    func saveImageToLocalDirectory(image: UIImage) -> URL? {
        // 获取图片的 JPEG 数据
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            print("Failed to convert image to JPEG")
            return nil
        }

        // 获取本地临时目录 URL
        let tempDirectory = FileManager.default.temporaryDirectory

        // 创建文件名，使用当前时间戳作为唯一标识
        let fileName = "image_\(Int(Date().timeIntervalSince1970)).jpg"

        // 构建完整文件路径
        let fileURL = tempDirectory.appendingPathComponent(fileName)

        do {
            // 将图片数据写入文件
            try imageData.write(to: fileURL)
            print("Image saved at: \(fileURL.absoluteString)")
            return fileURL
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }

    private func UpdateImageInfo(urlStr: String) {
        HUD.showLoading()
        APIProvider.shared.request(.uploadConfig, model: UpdateHeadInfo.self) { result in
            HUD.hideNow()

            switch result {
            case let .success(response):

                // 处理响应
                let m = response

                let s3Client = S3ClientUtils(accessKey: m.accessKey, secretKey: m.secretKey, token: m.token, endpoint: m.endpoint)

                HUD.showLoading()
                s3Client.uploadImageToS3(filePath: urlStr, model: m) { imgUrl, _ in
                    HUD.hideNow()
                    if let imgUrl, !imgUrl.isEmpty {
                        viewModel.info.headPortrait = imgUrl
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
        APIProvider.shared.request(.editUserInfo(headPortrait: imgUrl, name: "", id: viewModel.info.id)) {
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

                viewModel.fetchUserInfo()

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

// #Preview {
//    SecurityView()
// }
