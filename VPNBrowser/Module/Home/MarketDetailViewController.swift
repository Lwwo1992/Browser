//
//  MarketDetailViewController.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/22.
//

import UIKit

class MarketDetailViewController: ViewController {
    override var rootView: AnyView? {
        return AnyView(MarketDetailView(viewModel: viewModel))
    }

    var viewModel = HomeViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
