//
//  ChangeNicknameViewController.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/8.
//

import UIKit

class ChangeNicknameViewController: ViewController {
    private lazy var doneButton = Button().then {
        $0.title("完成")
            .titleFont(.systemFont(ofSize: 14))
            .tapAction = { [weak self] in
                guard let self else { return }
                guard let text = textField.text, text.count > 0 else {
                    HUD.showTipMessage("请输入昵称")
                    return
                }

                /// 修改昵称
                updateUserInfo()
            }
    }

    private lazy var textField = TextField().then {
        $0.placeholder = "用户昵称"
        $0.text = LoginManager.shared.info.name
        $0.backgroundColor = UIColor.white
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.layer.cornerRadius = 8
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension ChangeNicknameViewController {
    override func initUI() {
        super.initUI()
        title = "修改昵称"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneButton)

        view.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(view.safeAreaTop).inset(8)
            make.height.equalTo(45)
        }

        let subTitleLabel = Label().then {
            $0.text("好名字可以更好彰显自己个性")
                .textColor(.gray)
                .font(.systemFont(ofSize: 12))
        }
        view.addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(8)
            make.leading.equalTo(textField)
            make.trailing.equalToSuperview().inset(16)
        }
    }
}

extension ChangeNicknameViewController {
    private func updateUserInfo() {
        HUD.showLoading()
        APIProvider.shared.request(.editUserInfo(headPortrait: "", name: textField.text ?? "", id: LoginManager.shared.info.id)) { [weak self] result in
            guard let self else { return }
            HUD.hideNow()
            switch result {
            case .success:
                HUD.showTipMessage("修改成功")

                LoginManager.shared.fetchUserInfo()

                if let navigationController = self.navigationController {
                    if let securityVC = navigationController.viewControllers.first(where: { $0 is SecurityViewController }) {
                        navigationController.popToViewController(securityVC, animated: true)
                    }
                }

            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }
}
