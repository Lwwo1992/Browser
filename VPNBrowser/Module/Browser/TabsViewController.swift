//
//  TabViewController.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/14.
//

import UIKit

class TabsViewController: ViewController {
    var model = HistoryModel()

    override var rootView: AnyView? {
        return AnyView(TabsView(bookmarkModel: model))
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
