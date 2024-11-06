//
//  BookmarkViewViewController.swift
//  Browser
//
//  Created by xyxy on 2024/10/18.
//

import UIKit

class BookmarkViewController: ViewController {
    var folderID: String = ""

    override var rootView: AnyView? {
        return AnyView(BookmarkView(id: folderID))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
