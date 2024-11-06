//
//  LoginViewController.swift
//  Browser
//
//  Created by xyxy on 2024/10/10.
//

import UIKit

class LoginViewController: ViewController {
    private var viewModel = LoginViewModel()
    
    override var rootView: AnyView? {
        return AnyView(LoginView(viewModel: viewModel))
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
