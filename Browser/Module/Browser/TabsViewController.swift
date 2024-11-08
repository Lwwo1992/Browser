//
//  TabViewController.swift
//  Browser
//
//  Created by xyxy on 2024/10/14.
//

import UIKit
import WebView

class TabsViewController: ViewController {
    var model = HistoryModel()
    var onBookmarkAdded: ((WebViewTab) -> Void)?
    var webViewStore = WebViewStore()

    override var rootView: AnyView? {
        return AnyView(TabsView(webViewStore: webViewStore, onBookmarkAdded: { [weak self] newBookmark in
            guard let self else { return }
            self.onBookmarkAdded?(newBookmark)
            self.navigationController?.popViewController(animated: true)
        }))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension TabsViewController {
    override func initUI() {
        super.initUI()
    }
}
