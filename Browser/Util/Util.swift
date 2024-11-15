//
//  Util.swift
//  Browser
//
//  Created by xyxy on 2024/10/15.
//

import Foundation

extension Util {
    static func formattedTime(from timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date)
    }

    /// 创建文件夹
    static func createFolderIfNotExists(_ url: URL) {
        if FileManager.default.fileExists(atPath: url.path) == false {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
            } catch let error {
                debugPrint(error.localizedDescription)
            }
        }
    }

    /// 获取 documents 目录
    static var documentsPath: String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }

    static func guideItemTap(_ model: GuideItem) {
        switch model.type {
        case "h5":
            let vc = WebViewController()
            vc.path = model.downloadUrl ?? ""
            Util.topViewController().navigationController?.pushViewController(vc, animated: true)
        case "app":
            // var openType: Int? = null,//5：落地页，4：app下载, 3：html, 2：url
            if model.openType == 5 {
                let vc = WebViewController()
                vc.path = model.downloadUrl ?? ""
                Util.topViewController().navigationController?.pushViewController(vc, animated: true)
            } else {
                Util.topViewController().popup.bottomSheet {
                    let view = DownloadBottomSheetView(frame: CGRect(x: 0, y: 0, width: Util.deviceWidth, height: 260))
                    view.model = model
                    return view
                }
            }

        case "applet":
            break
        default:
            break
        }
    }

    static func formatFileSize(_ size: Int64) -> String {
        let units = ["B", "KB", "MB", "GB"]
        var sizeInUnit = Double(size)
        var unitIndex = 0

        while sizeInUnit >= 1024 && unitIndex < units.count - 1 {
            sizeInUnit /= 1024
            unitIndex += 1
        }

        if sizeInUnit.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f %@", sizeInUnit, units[unitIndex])
        } else {
            return String(format: "%.2f %@", sizeInUnit, units[unitIndex])
        }
    }

    static func isValidPassword(_ password: String) -> Bool {
        // 检测密码长度是否在 8 到 16 位之间
        if password.count < 8 || password.count > 16 {
            HUD.showTipMessage("密码必须是 8 到 16 位")
            return false
        }

        // 纯数字检测正则
        let pureNumberRegex = "^[0-9]{8,16}$"

        // 判断是否为纯数字
        let isPureNumber = NSPredicate(format: "SELF MATCHES %@", pureNumberRegex).evaluate(with: password)
        if isPureNumber {
            HUD.showTipMessage("密码不能是纯数字")
            return false
        }

        // 检查是否包含字母
        let containsLetterRegex = ".*[A-Za-z]+.*"
        let containsLetter = NSPredicate(format: "SELF MATCHES %@", containsLetterRegex).evaluate(with: password)
        if !containsLetter {
            HUD.showTipMessage("密码必须包含字母")
            return false
        }

        // 检查是否包含数字
        let containsNumberRegex = ".*\\d+.*"
        let containsNumber = NSPredicate(format: "SELF MATCHES %@", containsNumberRegex).evaluate(with: password)
        if !containsNumber {
            HUD.showTipMessage("密码必须包含数字")
            return false
        }

        // 检查是否包含特殊字符
        let containsSpecialCharRegex = ".*[!@#$%^&*.,]+.*"
        let containsSpecialChar = NSPredicate(format: "SELF MATCHES %@", containsSpecialCharRegex).evaluate(with: password)
        if !containsSpecialChar {
            HUD.showTipMessage("密码必须包含特殊字符")
            return false
        }

        return true
    }

    /// 根据路径 计算 数据大小
    static func getFileSize(dbPath: String) -> Int64? {
        // 查询两个表的数据
        let searchHistoryArray = DBaseManager.share.qureyFromDb(fromTable: S.Table.searchHistory, cls: HistoryModel.self) ?? []
        let browseHistoryArray = DBaseManager.share.qureyFromDb(fromTable: S.Table.browseHistory, cls: HistoryModel.self) ?? []

        // 累加两个数组的总大小
        let totalSize = searchHistoryArray.reduce(0) { $0 + $1.estimatedSize() } +
            browseHistoryArray.reduce(0) { $0 + $1.estimatedSize() }

        return totalSize
    }

    static func createQRCodeImage(content: String) -> UIImage? {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        let data = content.data(using: .utf8)
        filter.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        guard let ciImage = filter.outputImage?.transformed(by: transform) else {
            return nil
        }
        return UIImage(ciImage: ciImage)
    }

    static func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = (Int(timeInterval) % 86400) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60

        return String(format: "%02d:%02d:%02d 到期", hours, minutes, seconds)
    }

    static func formatSeconds(_ timeInterval: TimeInterval) -> String {
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d", seconds)
    }

    // 判断是否是有效的 App Store 链接
    static func canOpenAppStore(url: URL) -> Bool {
        // 检查是否是以 'https://apps.apple.com/' 或 'itms-apps://' 开头的 URL
        return url.absoluteString.lowercased().hasPrefix("https://apps.apple.com/") || url.absoluteString.lowercased().hasPrefix("itms-apps://")
    }
}

extension Util {
    static func getImageUrl(from path: String?) -> URL? {
        guard let path = path else {
            print("Invalid path.")
            return nil
        }

        let components = path.split(separator: "/")
        guard let firstComponent = components.first else {
            print("Invalid path components.")
            return nil
        }

        // 获取对应的 imageUrl
        if let anonymous = S.Config.anonymous?.bucketMap?[String(firstComponent)],
           let imageUrl = anonymous.imageUrl {
            let modifiedUrl = imageUrl.replacingOccurrences(of: "/\(firstComponent)", with: "")
            let urlString = modifiedUrl + path

            // 判断 urlString 是否包含 sslimg
            if urlString.lowercased().contains("sslimg") {
                // 下载并解密图片，返回本地 URL
                return downloadAndDecryptImageSync(from: urlString)
            } else {
                return URL(string: urlString)
            }
        } else {
            print("No corresponding guide found in bucketMap or image URL is missing.")
            return nil
        }
    }

    static func getGuideImageUrl(from path: String?) -> URL? {
        guard let path = path else {
            print("Invalid path.")
            return nil
        }

        let components = path.split(separator: "/")
        guard let firstComponent = components.first else {
            print("Invalid path components.")
            return nil
        }

        if let guideBucketInfo = S.Config.guideAnonymous?.bucketMap?[String(firstComponent)],
           let imageUrl = guideBucketInfo.imageUrl {
            let modifiedUrl = imageUrl.replacingOccurrences(of: "/\(firstComponent)", with: "")
            let urlString = modifiedUrl + path

            // 判断 urlString 是否包含 sslimg
            if urlString.lowercased().contains("sslimg") {
                // 下载并解密图片，返回本地 URL
                return downloadAndDecryptImageSync(from: urlString)
            } else {
                return URL(string: urlString)
            }
        } else {
            print("No corresponding guide found in bucketMap or image URL is missing.")
            return nil
        }
    }

    // 下载并解密图片（同步方法）
    private static func downloadAndDecryptImageSync(from urlString: String) -> URL? {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return nil
        }

        // Create a semaphore to block the current thread until the image is downloaded and decrypted
        let semaphore = DispatchSemaphore(value: 0)

        var resultURL: URL?

        // 下载图片数据
        downloadImageData(from: url) { data in
            // 解密图片数据
            let decryptedData = decodeIMGFileToString(data: data)

            // 将解密后的数据保存到本地
            if let fileURL = saveDecryptedData(decryptedData) {
                print("Image saved to: \(fileURL)")
                resultURL = fileURL
            } else {
                print("Failed to save decrypted image.")
                resultURL = nil
            }

            // Signal that the task is complete
            semaphore.signal()
        }

        // Block the current thread until the download and decryption is complete
        semaphore.wait()

        // Return the result URL (it could be nil if there was an issue)
        return resultURL
    }

    // 下载图片数据（异步）
    private static func downloadImageData(from url: URL, completion: @escaping (Data) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                completion(Data()) // Return empty data on failure
                return
            }
            if let data = data {
                completion(data) // Pass the downloaded data to the completion handler
            } else {
                completion(Data()) // Return empty data if no data
            }
        }.resume()
    }

    // 解密数据并保存
    private static func saveDecryptedData(_ data: [UInt8]?) -> URL? {
        guard let decryptedData = data else {
            print("No decrypted data to save.")
            return nil
        }

        // 将解密数据保存到本地
        let fileManager = FileManager.default
        let filePath = getLocalFilePath()

        let fileData = Data(decryptedData)
        do {
            try fileData.write(to: filePath)
            print("File saved to: \(filePath)")
            return filePath
        } catch {
            print("Failed to save decrypted image: \(error.localizedDescription)")
            return nil
        }
    }

    // 获取本地保存路径
    private static func getLocalFilePath() -> URL {
        let tempDirectory = FileManager.default.temporaryDirectory
        return tempDirectory.appendingPathComponent("decrypted_image.png")
    }
    
    private static func decodeIMGFileToString(data: Data) -> [UInt8] {
        var temp: [UInt8] = []

        let startTime = Date()

        let len = data.count
        guard len > 0 else { return [] }

        // 获取第一个字节作为掩码
        let mask = data[0]

        // 初始化临时数组
        temp = [UInt8](repeating: 0, count: len - 1)

        // 对数据进行 XOR 解码（从第1个字节开始）
        for i in 1 ..< len {
            temp[i - 1] = data[i] ^ mask
        }

        // 打印解码所用的时间（可选）
        let timeElapsed = Date().timeIntervalSince(startTime)
        print("Decoding took \(timeElapsed) seconds")

        return temp
    }
}
