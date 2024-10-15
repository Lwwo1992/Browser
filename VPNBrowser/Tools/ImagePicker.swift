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
    static let shared = S3ClientUtils()
    
    private var transferUtility: AWSS3TransferUtility?


    init() {
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1,
            identityPoolId: "YOUR_IDENTITY_POOL_ID") // 替换为您的身份池ID
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        self.transferUtility = AWSS3TransferUtility.default()
    }

   
    func upload(filePath: String, bucket: String, uploadAddrPrefix: String) {
        let fileURL = URL(fileURLWithPath: filePath)
        let expression = AWSS3TransferUtilityUploadExpression()
        
        transferUtility?.uploadFile(fileURL,
                                     bucket: bucket,
                                     key: uploadAddrPrefix + fileURL.lastPathComponent,
                                     contentType: "image/jpeg",
                                     expression: expression) { (task, error) in
            if let error = error {
                print("Upload failed with error: \(error)")
            } else {
                print("Upload successful")
            }
        }
    }
}
