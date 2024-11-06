//
//  ImagePicker.swift
//  Browser
//
//  Created by wei Chen on 2024/10/14.
//

import SwiftUI
import UIKit

import AWSMobileClient
import AWSS3

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
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
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
//            let credentialsProvider = AWSBasicSessionCredentialsProvider(accessKey: accessKey,
//                                                                        secretKey: secretKey,
//                                                                        sessionToken: "")

        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)

        // 创建服务配置
        let configuration = AWSServiceConfiguration(region: .USEast1, endpoint: AWSEndpoint(urlString: endpoint), credentialsProvider: credentialsProvider)

        // 设置默认的服务配置
        AWSServiceManager.default().defaultServiceConfiguration = configuration

        // 初始化 TransferUtility
        transferUtility = AWSS3TransferUtility.default()
        AWSDDLog.sharedInstance.logLevel = .verbose
        AWSDDLog.add(AWSDDTTYLogger.sharedInstance) // 将日志输出到控制台
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

    /*

     func uploadImageToS3(filePath: String, model: UpdateHeadInfo, completion: @escaping (String?, Error?) -> Void) {

         let fileURL = URL(fileURLWithPath: filePath)
         // 创建默认的 AWSS3TransferManager 实例
         let transferManager = AWSS3TransferManager.default()

         let fileLast = fileURL.lastPathComponent
         let key = "\(model.uploadAddrPrefix)\(fileLast)"

         // 创建上传请求
         let uploadRequest = AWSS3TransferManagerUploadRequest()
         uploadRequest?.bucket = model.bucket // 替换为你的 S3 桶名
         uploadRequest?.key = key // 替换为上传的文件名
         uploadRequest?.body = fileURL // 替换为你要上传的文件路径

         // 检查 uploadRequest 是否为非 nil
         guard let uploadRequest = uploadRequest else {
             print("Failed to create upload request")
             completion(nil, NSError(domain: "UploadError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create upload request"]))
             return
         }

         // 构建图片的 URL
         let imgUrl = "\(model.endpoint)/\(model.bucket)/\(key)"

         // 上传文件
         transferManager.upload(uploadRequest).continueWith { (task) -> AnyObject? in
             if let error = task.error {
                 print("上传失败：\(error)")
                 DispatchQueue.main.async {
                     completion(nil, error) // 上传失败时回调错误
                 }
             } else {
                 print("上传成功！图片的访问地址为: \(imgUrl)")
                 DispatchQueue.main.async {
                     completion(imgUrl, nil) // 上传成功时回调图片 URL
                 }
             }
             return nil
         }
     }
     */
    func uploadImageToS3(filePath: String, model: UpdateHeadInfo, completion: @escaping (String?, Error?) -> Void) {
        let fileURL = URL(fileURLWithPath: filePath)
        // 创建默认的 AWSS3TransferManager 实例
        let transferManager = AWSS3TransferManager.default()

        let fileLast = fileURL.lastPathComponent
        let key = "\(model.uploadAddrPrefix)\(fileLast)"

        // 创建上传请求
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.bucket = model.bucket // 替换为你的 S3 桶名
        uploadRequest?.key = key // 替换为上传的文件名
        uploadRequest?.body = fileURL // 替换为你要上传的文件路径

        // 检查 uploadRequest 是否为非 nil
        guard let uploadRequest = uploadRequest else {
            print("Failed to create upload request")
            completion(nil, NSError(domain: "UploadError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create upload request"]))
            return
        }

        // 构建图片的 URL
        let address = "/\(model.bucket)/\(key)"

        // 上传文件
        transferManager.upload(uploadRequest).continueWith { task -> AnyObject? in
            if let error = task.error {
                print("上传失败：\(error)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    HUD.showTipMessage("上传失败：\(error)")
                }
                DispatchQueue.main.async {
                    completion(nil, error) // 上传失败时回调错误
                }
            } else {
                print("上传成功！图片的访问地址为: \(address)")
                DispatchQueue.main.async {
                    completion(address, nil) // 上传成功时回调图片 URL
                }
            }
            return nil
        }
    }
}
