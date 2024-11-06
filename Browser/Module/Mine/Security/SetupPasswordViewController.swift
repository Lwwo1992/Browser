//
//  SetupViewController.swift
//  Browser
//
//  Created by xyxy on 2024/10/18.
//

import UIKit

class SetupPasswordViewController: ViewController {
    override var rootView: AnyView? {
        return AnyView(SetupPasswordView())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension SetupPasswordViewController {
    override func initUI() {
        super.initUI()
        title = "设置密码"
    }
}
