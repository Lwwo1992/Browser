//
//  UserGuideViewController.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/16.
//

import UIKit

class UserGuideViewController: ViewController {
    private var viewModel = UserGuideViewModel()

    override var rootView: AnyView? {
        return AnyView(UserGuideView(viewModel: viewModel))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
