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
    }
    
    private lazy var textField = TextField().then {
        $0.placeholder = "用户昵称"
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
