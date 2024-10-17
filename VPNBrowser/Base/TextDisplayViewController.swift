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

            let htmlString = """
            <html>
            <head>
            <style type="text/css">
            body { font-size: 150%; } /* 设置字体大小为 150% */
            p { font-size: 150%; } /* 也可以单独设置 p 标签的字体大小 */
            </style>
            </head>
            <body>\(content)</body>
            </html>
            """
            webView.loadHTMLString(htmlString, baseURL: nil)
        }
    }

    private lazy var webView = WKWebView().then {
        $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        /// 不需要 滚动条
        $0.scrollView.showsVerticalScrollIndicator = false
        $0.scrollView.showsHorizontalScrollIndicator = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(view.safeAreaTop).inset(10)
            make.bottom.equalTo(view.safeAreaBottom)
        }
    }
}
