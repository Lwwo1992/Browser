//
//  ChangePasswordViewController.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/17.
//

import UIKit

class ChangePasswordViewController: ViewController {
    override var rootView: AnyView? {
        return AnyView(ChangePasswordView())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension ChangePasswordViewController {
    override func initUI() {
        super.initUI()
        title = "修改密码"
    }
}
