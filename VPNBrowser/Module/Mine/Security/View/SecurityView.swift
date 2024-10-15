//
//  SecurityView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/8.
//
import SwiftUI
import WTool
import AWSMobileClient
import AWSS3

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

    @State private var selectedImage: UIImage? = nil
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
                .cancel()
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
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .foregroundColor(.gray)
            }
        }
    }

    private func handleTap(for item: SecurityOption) {
        switch item {
        case .avatar:
            isShowingActionSheet = true
        default:
            break
        }
    }

    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {

        
        imagePickerManager.pickImage(sourceType: sourceType, from: Util.topViewController()) { image,urlstring in
            if let image = image {
                selectedImage = image
                // 这里可以添加额外的处理，例如上传头像
                
                UpdateImageInfo(urlStr: urlstring ?? "")
            }
        }
    }
    
    private func UpdateImageInfo(urlStr:String){
        
        
        
        APIProvider.shared.request(.uploadConfig(image: selectedImage ?? UIImage()), model: UpdateHeadInfo.self) { result in
            switch result {
            case .success(let response):
                
                // 处理响应
                let m = response 
                
 
                let s3Client = S3ClientUtils(accessKey: m.accessKey, secretKey: m.secretKey, token: m.token, endpoint: m.endpoint)
              
                s3Client.upload(filePath: urlStr, model:m)
                
                
            case .failure(let error):
                print("请求失败，错误：\(error)")
            }
        }
    
    }
    
    
    private func rightTitle(for item: SecurityOption) -> String? {
        switch item {
        case .nickname:
            return LoginManager.shared.loginInfo?.account
        case .phoneNumber:
            return LoginManager.shared.loginInfo?.mobile.maskedAccount
        case .email:
            return LoginManager.shared.loginInfo?.mailbox.maskedAccount
        case .account:
            return LoginManager.shared.loginInfo?.account
        default:
            return nil
        }
    }
}

#Preview {
    SecurityView()
}
