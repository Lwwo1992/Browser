//
//  TabViewController.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/14.
//

import UIKit

class TabsViewController: ViewController {
    var model = HistoryModel()
    var onBookmarkAdded: ((HistoryModel) -> Void)?

    override var rootView: AnyView? {
        return AnyView(TabsView(bookmarkModel: model, onBookmarkAdded: { [weak self] newBookmark in
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
