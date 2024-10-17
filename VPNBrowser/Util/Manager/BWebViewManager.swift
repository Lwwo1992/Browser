//
//  BWebViewManager.swift
//  ActivityCommunity
//
//  Created by wei Chen on 2024/10/12.
//

import UIKit
import WebKit

enum BrowerHistroyType {
    case video // 视频
    case movie // 影视
    case book // 小说
    case comic // 漫画
    case collec // 集合
    case other // 所有
}

class BWebViewManager: NSObject {
    static let share = BWebViewManager()

    // 检查是否为下载链接
    func isDownloadLink(url: URL) -> Bool {
        let downloadExtensions = ["mp4", "pdf", "txt", "zip", "rar"]
        return downloadExtensions.contains(url.pathExtension) || url.absoluteString.contains("download")
    }

    // 处理下载，并保存到指定路径
    func handleDownload(url: URL, completion: @escaping (_ filePath: URL?, _ fileName: String?, _ fileSize: Int64?) -> Void) {
        print("准备下载：\(url)")

        let request = URLRequest(url: url)

        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            guard error == nil else {
                print("请求失败: \(error?.localizedDescription ?? "未知错误")")
                completion(nil, nil, nil) // 请求失败时返回 nil
                return
            }

            // 检查 MIME 类型
            if let mimeType = response?.mimeType, self.isValidMimeType(mimeType) {
                // 如果 MIME 类型有效，开始下载文件
                self.downloadFile(from: url, mimeType: mimeType, completion: completion)
            } else {
                print("无效的文件类型，未下载: \(response?.mimeType ?? "未知 MIME 类型")")
                completion(nil, nil, nil) // MIME 类型无效时返回 nil
            }
        }

        task.resume() // 开始请求
    }

    // 根据 MIME 类型判断文件类型是否有效
    private func isValidMimeType(_ mimeType: String) -> Bool {
        let validMimeTypes: Set<String> = [
            "application/pdf",
            "video/mp4",
            "audio/mpeg",
            "text/plain",
            "application/zip",
            "application/x-rar-compressed",
            "image/jpeg",
            "image/png",
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            "application/msword",
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            "application/vnd.ms-excel",
            "application/vnd.openxmlformats-officedocument.presentationml.presentation",
            "application/vnd.ms-powerpoint",
            "application/octet-stream", // 默认二进制流
        ]

        return validMimeTypes.contains(mimeType)
    }

    // 下载文件
    private func downloadFile(from url: URL, mimeType: String, completion: @escaping (_ filePath: URL?, _ fileName: String?, _ fileSize: Int64?) -> Void) {
        let downloadTask = URLSession.shared.downloadTask(with: url) { location, _, error in
            guard let location = location else {
                print("下载失败: \(error?.localizedDescription ?? "未知错误")")
                completion(nil, nil, nil) // 下载失败时返回 nil
                return
            }

            // 获取原始文件名
            var originalFileName = UUID().uuidString

            // 检查 MIME 类型并根据需要添加后缀
            if !self.hasValidExtension(fileName: originalFileName, mimeType: mimeType) {
                // 根据 MIME 类型添加合适的后缀
                originalFileName = self.addExtension(for: mimeType, to: originalFileName)
            }

            // 生成目标文件路径
            let destinationURL = self.getDestinationPath(for: originalFileName)

            do {
                // 移动下载的文件到目标位置
                try FileManager.default.moveItem(at: location, to: destinationURL)
                print("文件已保存到: \(destinationURL)")

                // 获取文件大小
                let fileAttributes = try FileManager.default.attributesOfItem(atPath: destinationURL.path)
                let fileSize = fileAttributes[FileAttributeKey.size] as? Int64

                // 下载成功，返回文件路径、文件名和文件大小
                completion(destinationURL, originalFileName, fileSize)
            } catch {
                print("下载文件保存失败: \(error.localizedDescription)")
                completion(nil, nil, nil) // 保存失败时返回 nil
            }
        }

        downloadTask.resume() // 开始下载
    }

    // 根据文件类型选择保存路径
    func getDestinationPath(for originalFileName: String) -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folderName = "Downloads" // 目标文件夹名称
        let folderPath = documentsPath.appendingPathComponent(folderName)

        // 如果文件夹不存在，则创建它
        if !FileManager.default.fileExists(atPath: folderPath.path) {
            do {
                try FileManager.default.createDirectory(at: folderPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("创建文件夹失败: \(error)")
            }
        }

        // 生成目标文件路径
        var destinationURL = folderPath.appendingPathComponent(originalFileName)

        // 检查文件是否已存在，如果存在，则重命名
        var fileIndex = 1
        while FileManager.default.fileExists(atPath: destinationURL.path) {
            let newFileNameWithIndex = "\(fileIndex)_\(originalFileName)"
            destinationURL = folderPath.appendingPathComponent(newFileNameWithIndex)
            fileIndex += 1
        }

        return destinationURL
    }

    // 检查文件名是否已经有有效的扩展名
    private func hasValidExtension(fileName: String, mimeType: String) -> Bool {
        let extensionMapping: [String: String] = [
            // 文档
            "application/pdf": "pdf",
            "application/msword": "doc",
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document": "docx",
            "application/vnd.ms-excel": "xls",
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet": "xlsx",
            "application/vnd.ms-powerpoint": "ppt",
            "application/vnd.openxmlformats-officedocument.presentationml.presentation": "pptx",
            "text/plain": "txt",

            // 图片
            "image/jpeg": "jpg",
            "image/png": "png",
            "image/gif": "gif",
            "image/bmp": "bmp",
            "image/svg+xml": "svg",
            "image/webp": "webp",

            // 音频
            "audio/mpeg": "mp3",
            "audio/wav": "wav",
            "audio/x-wav": "wav",
            "audio/ogg": "ogg",
            "audio/mp4": "m4a",
            "audio/x-m4a": "m4a",

            // 视频
            "video/mp4": "mp4",
            "video/x-msvideo": "avi",
            "video/x-matroska": "mkv",
            "video/x-flv": "flv",
            "video/x-ms-wmv": "wmv",
            "video/quicktime": "mov",

            // 压缩文件
            "application/zip": "zip",
            "application/x-rar-compressed": "rar",
            "application/gzip": "gz",
            "application/x-tar": "tar",

            // 网页文件
            "text/html": "html",
            "text/css": "css",
            "text/javascript": "js",
            "application/javascript": "js",

            // 默认二进制流
            "application/octet-stream": "bin", // 默认二进制流
        ]

        if let validExtension = extensionMapping[mimeType] {
            return fileName.hasSuffix(validExtension)
        }

        return false
    }

    // 根据 MIME 类型添加合适的后缀
    private func addExtension(for mimeType: String, to fileName: String) -> String {
        let extensionMapping: [String: String] = [
            // 文档
            "application/pdf": "pdf",
            "application/msword": "doc",
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document": "docx",
            "application/vnd.ms-excel": "xls",
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet": "xlsx",
            "application/vnd.ms-powerpoint": "ppt",
            "application/vnd.openxmlformats-officedocument.presentationml.presentation": "pptx",
            "text/plain": "txt",

            // 图片
            "image/jpeg": "jpg",
            "image/png": "png",
            "image/gif": "gif",
            "image/bmp": "bmp",
            "image/svg+xml": "svg",
            "image/webp": "webp",

            // 音频
            "audio/mpeg": "mp3",
            "audio/wav": "wav",
            "audio/x-wav": "wav",
            "audio/ogg": "ogg",
            "audio/mp4": "m4a",
            "audio/x-m4a": "m4a",

            // 视频
            "video/mp4": "mp4",
            "video/x-msvideo": "avi",
            "video/x-matroska": "mkv",
            "video/x-flv": "flv",
            "video/x-ms-wmv": "wmv",
            "video/quicktime": "mov",

            // 压缩文件
            "application/zip": "zip",
            "application/x-rar-compressed": "rar",
            "application/gzip": "gz",
            "application/x-tar": "tar",

            // 网页文件
            "text/html": "html",
            "text/css": "css",
            "text/javascript": "js",
            "application/javascript": "js",

            // 默认二进制流
            "application/octet-stream": "bin", // 默认二进制流
        ]

        if let validExtension = extensionMapping[mimeType] {
            return fileName + "." + validExtension
        }

        return fileName // 如果 MIME 类型未知，则不添加后缀
    }
}
