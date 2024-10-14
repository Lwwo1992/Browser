//
//  WebViewController.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/14.
//

import UIKit
import WebKit

class BrowserWebViewController: ViewController {
    var path: String = ""

    override var rootView: AnyView? {
        let viewModel = WebViewViewModel()
        viewModel.urlString = path
        return AnyView(BrowserWebView(viewModel: viewModel))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
}
