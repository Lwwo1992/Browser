//
//  TextDisplayViewController.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/11.
//

import UIKit
import WebKit

class TextDisplayViewController: ViewController {
    var content: String? {
        didSet {
            guard let content else {
                return
            }

            webView.loadHTMLString(content, baseURL: nil)
        }
    }

    private lazy var webView = WKWebView().then {
        $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(view.safeAreaTop)
            make.bottom.equalTo(view.safeAreaBottom)
        }
    }
}
