//
//  DownloadView.swift
//  Browser
//
//  Created by xyxy on 2024/10/15.
//

import UIKit

class DownloadBottomSheetView: UIView {
    var model: GuideItem? {
        didSet {
            guard let model else {
                return
            }

            titleLabel.text = model.name
            imageView.setImage(with: Util.getImageUrl(from: model.icon))

            if let url = model.downloadUrl {
                getFileSize(from: url) { [weak self] size, error in
                    guard let self else { return }
                    DispatchQueue.main.async {
                        if let size = size {
                            self.sizeLabel.text = Util.formatFileSize(size)
                        } else if let error = error {
                            print("获取文件大小失败: \(error)")
                        }
                    }
                }
                addressLabel.text(url)
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
        $0.text("未知")
            .font(.systemFont(ofSize: 14))
        $0.numberOfLines = 1
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
                guard let self, let model, let urlString = model.downloadUrl, let url = URL(string: urlString) else { return }

                if Util.canOpenAppStore(url: url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else if BWebViewManager.share.isDownloadLink(url: url) {
                    downloadFile()
                } else {
                    HUD.showTipMessage("非下载地址")
                }
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
            make.right.equalToSuperview().inset(80)
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

    private func getFileSize(from urlStr: String, completion: @escaping (Int64?, Error?) -> Void) {
        guard let url = URL(string: urlStr) else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"

        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  let contentLength = httpResponse.allHeaderFields["Content-Length"] as? String,
                  let fileSize = Int64(contentLength) else {
                completion(nil, nil)
                return
            }

            completion(fileSize, nil)
        }
        task.resume()
    }

    private func downloadFile() {
        guard let model, let urlString = model.downloadUrl, let url = URL(string: urlString) else {
            return
        }

        let downloadTask = URLSession.shared.downloadTask(with: url) { location, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    debugPrint("\(error.localizedDescription)")
                }
                return
            }

            guard let location = location else {
                DispatchQueue.main.async {
                    debugPrint("Download failed")
                }
                return
            }

            if !FileManager.default.fileExists(atPath: S.Files.downloads.path) {
                Util.createFolderIfNotExists(S.Files.downloads)
            }

            let destinationURL = S.Files.downloads.appendingPathComponent(response?.suggestedFilename ?? url.lastPathComponent)

            do {
                // 移动文件到目标位置
                try FileManager.default.moveItem(at: location, to: destinationURL)

                // 获取文件大小
                let attributes = try FileManager.default.attributesOfItem(atPath: destinationURL.path)
                let fileSize = attributes[.size] as? Int64 ?? 0 // 文件大小，单位为字节

                DispatchQueue.main.async {
                    let model = DownloadModel()
                    model.url = destinationURL.path
                    model.size = fileSize
                    model.title = response?.suggestedFilename ?? url.lastPathComponent
                    DBaseManager.share.insertToDb(objects: [model], intoTable: S.Table.download)
                    HUD.showTipMessage("下载成功")
                }
            } catch {
                DispatchQueue.main.async {
                    debugPrint(error.localizedDescription)
                }
            }
        }

        downloadTask.resume()
    }
}
