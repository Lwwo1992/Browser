//
//  MineViewController.swift
//  Browser
//
//  Created by xyxy on 2024/10/8.
//

import SwiftUI
import UIKit

class MineViewController: ViewController {
    override var rootView: AnyView? {
        return AnyView(MineView())
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

extension MineViewController {
    override func initUI() {
        super.initUI()
    }
}
