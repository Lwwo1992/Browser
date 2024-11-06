//
//  AgreedBottomSheet.swift
//  Browser
//
//  Created by xyxy on 2024/10/23.
//

import UIKit

class AgreedBottomSheet: UIView {
    var onAgreed: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white

        let titleLabel = Label().then {
            $0.text("服务协议及隐私保护")
                .font(.systemFont(ofSize: 30, weight: .medium))
        }

        let subTitleLabel = Label().then {
            $0.text("我已阅并同意《服务协议》《隐私政策》")
                .font(.systemFont(ofSize: 14, weight: .medium))
                .textColor(.black.withAlphaComponent(0.5))
            $0.numberOfLines = 0
            $0.isUserInteractionEnabled = true
        }

        let notAgreedButton = Button().then {
            $0.title("不同意")
                .titleFont(.systemFont(ofSize: 14))
                .titleColor(.gray)
                .cornerRadius(5)
                .borderWidth(1, color: .gray)
                .tapAction = { [weak self] in
                    guard let self else { return }
                    self.tf_hide()
                }
        }

        let agreedButton = Button().then {
            $0.title("同意并登录")
                .titleFont(.systemFont(ofSize: 14))
                .titleColor(.white)
                .cornerRadius(5)
                .backgroundColor(.blue)
                .tapAction = { [weak self] in
                    guard let self else { return }
                    self.tf_hide()
                    onAgreed?()
                }
        }

        [titleLabel, subTitleLabel, notAgreedButton, agreedButton].forEach { addSubview($0) }

        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(30)
        }

        subTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
        }

        let width = (self.width - 32 - 20) / 3

        notAgreedButton.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(subTitleLabel).offset(60)
            make.height.equalTo(50)
            make.width.equalTo(width)
        }

        agreedButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.centerY.equalTo(notAgreedButton)
            make.height.equalTo(notAgreedButton)
            make.width.equalTo(width * 2)
        }

        let fullText = "我已阅并同意《服务协议》《隐私政策》"
        let attributedString = NSMutableAttributedString(string: fullText)

        let termsRange = (fullText as NSString).range(of: "《服务协议》")
        attributedString.addAttribute(.foregroundColor, value: UIColor.blue, range: termsRange)
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: termsRange)

        let privacyRange = (fullText as NSString).range(of: "《隐私政策》")
        attributedString.addAttribute(.foregroundColor, value: UIColor.blue, range: privacyRange)
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: privacyRange)

        subTitleLabel.attributedText = attributedString

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOnLabel(_:)))
        subTitleLabel.addGestureRecognizer(tapGesture)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AgreedBottomSheet {
    @objc private func handleTapOnLabel(_ recognizer: UITapGestureRecognizer) {
        let text = "我已阅并同意《服务协议》《隐私政策》"
        let termsRange = (text as NSString).range(of: "《服务协议》")
        let privacyRange = (text as NSString).range(of: "《隐私政策》")

        if let label = recognizer.view as? UILabel {
            let tapLocation = recognizer.location(in: label)
            let textStorage = NSTextStorage(attributedString: label.attributedText!)
            let layoutManager = NSLayoutManager()
            let textContainer = NSTextContainer(size: label.bounds.size)
            textContainer.lineFragmentPadding = 0
            textContainer.lineBreakMode = label.lineBreakMode
            textContainer.maximumNumberOfLines = label.numberOfLines
            layoutManager.addTextContainer(textContainer)
            textStorage.addLayoutManager(layoutManager)

            let characterIndex = layoutManager.characterIndex(for: tapLocation, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

            if NSLocationInRange(characterIndex, termsRange) {
                fetchAgreementContent(requestData: 3, titleText: "服务协议")
            } else if NSLocationInRange(characterIndex, privacyRange) {
                fetchAgreementContent(requestData: 2, titleText: "隐私协议")
            }
        }
    }

    private func fetchAgreementContent(requestData: Int, titleText: String) {
        tf_hide()
        
        HUD.showLoading()
        APIProvider.shared.request(.getConfigByType(data: requestData), model: ConfigByTypeModel.self) { result in
            HUD.hideNow()
            switch result {
            case let .success(model):
                if let content = model.content {
                    let vc = TextDisplayViewController()
                    vc.title = titleText
                    vc.content = content
                    Util.topViewController().navigationController?.pushViewController(vc, animated: true)
                }
            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }
}
