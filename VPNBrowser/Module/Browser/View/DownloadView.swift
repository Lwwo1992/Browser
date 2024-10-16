//
//  DownloadView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/15.
//

import UIKit

class DownloadView: UIView {
    var model: GuideItem? {
        didSet {
            guard let model else {
                return
            }

            titleLabel.text = model.name
            imageView.setImage(with: Util.getCompleteImageUrl(from: model.icon))

            if let url = model.downloadUrl {
                getFileSize(from: url) { [weak self] size, error in
                    guard let self else { return }
                    if let size = size {
                        self.sizeLabel.text = formatFileSize(size)
                    } else if let error = error {
                        print("获取文件大小失败: \(error)")
                    }
                }
            }
        }
    }

//    private lazy var cancelButton = Button().then {
//        $0.title("取消")
//            .titleFont(.systemFont(ofSize: 14))
//            .titleColor(.gray)
//    }

    private lazy var titleLabel = Label().then {
        $0.text("下载文件")
            .font(.systemFont(ofSize: 16))
    }

    private lazy var imageView = UIImageView().then {
        $0.layer.cornerRadius = 5
    }

    private lazy var addressLabel = Label().then {
        $0.text("badui.com")
            .font(.systemFont(ofSize: 14))
    }

    private lazy var sizeLabel = Label().then {
        $0.text("-")
            .font(.systemFont(ofSize: 12))
    }

    private lazy var downloadButton = Button().then {
        $0.title("下载")
            .titleFont(.systemFont(ofSize: 14))
            .borderWidth(1, color: .gray)
            .cornerRadius(15)
            .tapAction = { [weak self] in
                guard let self else { return }

                download()
            }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white

//        addSubview(cancelButton)
        addSubview(titleLabel)
        addSubview(imageView)
        addSubview(addressLabel)
        addSubview(sizeLabel)
        addSubview(downloadButton)

//        cancelButton.snp.makeConstraints { make in
//            make.left.equalToSuperview().inset(16)
//            make.centerY.equalTo(titleLabel)
//        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.centerX.equalToSuperview()
        }

        imageView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.size.equalTo(40)
        }

        addressLabel.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).offset(6)
            make.top.equalTo(imageView.snp.top)
        }

        sizeLabel.snp.makeConstraints { make in
            make.left.equalTo(addressLabel.snp.left)
            make.bottom.equalTo(imageView.snp.bottom)
        }

        downloadButton.snp.makeConstraints { make in
            make.width.equalTo(50)
            make.height.equalTo(30)
            make.right.equalToSuperview().inset(16)
            make.centerY.equalTo(imageView)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func getFileSize(from url: String, completion: @escaping (Int64?, Error?) -> Void) {
        APIProvider.shared.request(.fileSize(url: url)) { result in
            switch result {
            case let .success(response):
                if let contentLength = response.response?.allHeaderFields["Content-Length"] as? String,
                   let size = Int64(contentLength) {
                    completion(size, nil)
                } else {
                    completion(nil, NSError(domain: "APIError", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法获取文件大小"]))
                }

            case let .failure(error):
                completion(nil, error) // 返回错误
            }
        }
    }

    private func formatFileSize(_ size: Int64) -> String {
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

    private func download() {
        guard let model, let url = model.downloadUrl else { return }

        APIProvider.shared.request(.downloadFile(url: url), progress: { response in
            let percentage = Int(response.progress * 100)
            DispatchQueue.main.async {
                self.downloadButton.title("\(percentage)%")
            }
        }) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(response):
                // 确保响应数据有效
                if (200 ... 299).contains(response.statusCode) {
                    let fileManager = FileManager.default
                    let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let fileURL = documentsURL.appendingPathComponent("downloadedFile") // 自定义文件名

                    do {
                        try response.data.write(to: fileURL)
                        self.downloadButton.title("成功")
                        print("文件已保存到: \(fileURL)")
                    } catch {
                        print("文件写入失败: \(error)")
                    }
                } else {
                    self.downloadButton.title("失败")
                    print("下载失败，状态码: \(response.statusCode)")
                }

            case let .failure(error):
                self.downloadButton.title("失败")
                print("请求失败: \(error)")
            }
        }
    }
}
