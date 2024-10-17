//
//  ReplaceBindingViewController.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/14.
//

import UIKit

class ReplaceBindingViewController: ViewController {
    var acctype: AccountType = .mailbox

    override var rootView: AnyView? {
        return AnyView(ReplaceBindingView(type: acctype))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension ReplaceBindingViewController {
    override func initUI() {
        super.initUI()
        title = "更换绑定"
    }
}
