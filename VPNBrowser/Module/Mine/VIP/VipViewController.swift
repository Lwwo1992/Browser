//
//  VipViewController.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/22.
//

import UIKit

class VipViewController: ViewController {
    override var rootView: AnyView? {
        return AnyView(VipView())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension VipViewController {
    override func initUI() {
        super.initUI()
        title = "会员"
    }
}
