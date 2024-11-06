//
//  AccountLoginViewController.swift
//  Browser
//
//  Created by xyxy on 2024/10/11.
//

import UIKit

class AccountLoginViewController: ViewController {
    override var rootView: AnyView? {
        return AnyView(AccountLoginView())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension AccountLoginViewController {
    override func initUI() {
        super.initUI()
        view.backgroundColor = .white
    }
}
