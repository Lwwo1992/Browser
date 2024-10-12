//
//  LoginViewController.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/10.
//

import UIKit

class LoginViewController: ViewController {
    override var rootView: AnyView? {
        return AnyView(LoginView())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension LoginViewController {
    override func initUI() {
        super.initUI()
        view.backgroundColor = .white
    }
}
