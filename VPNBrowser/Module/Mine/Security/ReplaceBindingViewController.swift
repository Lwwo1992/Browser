//
//  ReplaceBindingViewController.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/14.
//

import UIKit

class ReplaceBindingViewController: ViewController {
    override var rootView: AnyView? {
        return AnyView(ReplaceBindingView())
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
