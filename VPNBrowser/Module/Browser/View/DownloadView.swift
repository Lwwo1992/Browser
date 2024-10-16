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
        $0.text("10KB")
            .font(.systemFont(ofSize: 12))
    }

    private lazy var downloadButton = Button().then {
        $0.title("下载")
            .titleFont(.systemFont(ofSize: 14))
            .borderWidth(1, color: .gray)
            .cornerRadius(15)
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

    func getFileSize(from url: String, completion: @escaping (Int64?, Error?) -> Void) {
        guard let model else {
            return completion(nil, nil)
        }
        
//        APITarget.share.request(.fileSize(url: model.downloadUrl)) { result in
//            switch result {
//            case let .success(response):
//                // 从响应头中获取 Content-Length
//                if let contentLength = response.response?.allHeaderFields["Content-Length"] as? String,
//                   let size = Int64(contentLength) {
//                    completion(size, nil) // 返回文件大小
//                } else {
//                    completion(nil, NSError(domain: "APIError", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法获取文件大小"]))
//                }
//
//            case let .failure(error):
//                completion(nil, error) // 返回错误
//            }
//        }
    }
}
