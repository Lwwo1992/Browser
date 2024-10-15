//
//  RecommendedModeViewController.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/9.
//

import UIKit

class RecommendedModeViewController: ViewController {
    var viewModel = ViewModel()
    
    override var rootView: AnyView? {
        return AnyView(RecommendedModeView(viewModel: viewModel))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension RecommendedModeViewController {
    override func initUI() {
        super.initUI()
    }
}
