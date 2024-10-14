//
//  BindingViewController.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/8.
//

import UIKit

class BindingViewController: ViewController {
    var type: AccountType = .mobile
    
    override var rootView: AnyView? {
        return AnyView(BindingView(type: type))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
