//
//  ImagePicker.swift
//  VPNBrowser
//
//  Created by wei Chen on 2024/10/14.
//

import SwiftUI
import UIKit 

import AWSS3
import AWSMobileClient


class ImagePicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private var completion: ((UIImage?, String?) -> Void)?

    func pickImage(sourceType: UIImagePickerController.SourceType, from viewController: UIViewController, completion: @escaping (UIImage?, String?) -> Void) {
        self.completion = completion

        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = sourceType

        viewController.present(imagePickerController, animated: true, completion: nil)
    }

    // UIImagePickerControllerDelegate方法
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            if let image = info[.originalImage] as? UIImage {
                // 获取图片的沙盒路径
                if let imageURL = info[.imageURL] as? URL {
                    // 缩放图片为 0.5
                    let scaledImage = self.scaleImage(image: image, scale: 0.5)
                    // 返回缩放后的图片和其路径
                    self.completion?(scaledImage, imageURL.path)
                } else {
                    // 如果没有找到图片路径，返回缩放后的图片
                    let scaledImage = self.scaleImage(image: image, scale: 0.5)
                    self.completion?(scaledImage, nil)
                }
            } else {
                self.completion?(nil, nil)
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        completion?(nil, nil)
    }

    // 缩放图片的方法
    private func scaleImage(image: UIImage, scale: CGFloat) -> UIImage? {
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(origin: .zero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
}


 

class S3ClientUtils {
    
        static let shared = S3ClientUtils(accessKey: "YOUR_ACCESS_KEY",
                                           secretKey: "YOUR_SECRET_KEY",
                                           token: "YOUR_SESSION_TOKEN",
                                           endpoint: "https://your-custom-endpoint.amazonaws.com")

        private var transferUtility: AWSS3TransferUtility?
 
    
        init(accessKey: String, secretKey: String, token: String, endpoint: String) {
            
            // 创建凭证提供者
            let credentialsProvider = AWSBasicSessionCredentialsProvider(accessKey: accessKey,
                                                                        secretKey: secretKey,
                                                                        sessionToken: token)
            
            // 创建服务配置
            let configuration = AWSServiceConfiguration(region: .USEast1, endpoint: AWSEndpoint(urlString: endpoint), credentialsProvider: credentialsProvider)

             

            // 设置默认的服务配置
            AWSServiceManager.default().defaultServiceConfiguration = configuration
            
            // 初始化 TransferUtility
            self.transferUtility = AWSS3TransferUtility.default()
 
            
        }
     
    func upload(filePath: String, model: UpdateHeadInfo) {
        let fileURL = URL(fileURLWithPath: filePath)
        print("Full file URL: \(fileURL.path)")

        // 检查 TransferUtility 是否初始化
        guard let transferUtility = transferUtility else {
            print("Transfer utility is not initialized.")
            return
        }

        let expression = AWSS3TransferUtilityUploadExpression()
        let fileLast = fileURL.lastPathComponent
        let key = "\(model.uploadAddrPrefix)\(fileLast)"

        // 打印桶名和键，便于调试
        print("Bucket: \(model.bucket)")
        print("Key: \(key)")

        // 检查文件是否存在
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            print("File does not exist at path: \(fileURL.path)")
            return
        }

        let mimeType = getMIMEType(for: key)

        // 设置进度回调
        expression.progressBlock = { (task, progress) in
            DispatchQueue.main.async {
                print("Upload progress: \(progress.fractionCompleted)")
            }
        }

        transferUtility.uploadFile(fileURL,
                                    bucket: model.bucket,
                                    key: key,
                                    contentType: mimeType,
                                    expression: expression) { (task, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Upload failed with error: \(error.localizedDescription)")
                } else {
                    print("Upload successful")
                }
            }
        }
    }

    
    func getMIMEType(for filename: String) -> String {
        if filename.hasSuffix("jpg") || filename.hasSuffix("jpeg") {
            return "image/jpeg"
        } else if filename.hasSuffix("png") {
            return "image/png"
        } else if filename.hasSuffix("mp4") || filename.hasSuffix("MP4") {
            return "video/mp4"
        } else {
            return "application/octet-stream" // 默认类型
        }
    }


}
