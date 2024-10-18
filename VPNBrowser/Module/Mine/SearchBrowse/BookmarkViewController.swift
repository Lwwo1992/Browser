//
//  BookmarkViewViewController.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/18.
//

import UIKit

class BookmarkViewController: ViewController {
    var bookmarks: [HistoryModel] = []

    override var rootView: AnyView? {
        return AnyView(BookmarkView(bookmarks: bookmarks))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
