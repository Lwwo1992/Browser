//
//  TabViewController.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/14.
//

import UIKit

class TabViewController: ViewController {
    var model = HistoryModel()

    override var rootView: AnyView? {
        return AnyView(TabView(bookmarkModel: model))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension TabViewController {
    override func initUI() {
        super.initUI()
    }
}
