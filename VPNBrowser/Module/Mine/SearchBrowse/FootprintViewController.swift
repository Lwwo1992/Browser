//
//  CollectViewController.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/9.
//

import UIKit

class FootprintViewController: ViewController {
    override var rootView: AnyView? {
        return AnyView(FootprintView())
    }

    private lazy var segmentedControl = UISegmentedControl(items: ["收藏", "历史"]).then {
        $0.selectedSegmentIndex = 0
        $0.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension FootprintViewController {
    override func initUI() {
        super.initUI()

        navigationItem.titleView = segmentedControl
    }

    @objc func segmentChanged(_ sender: UISegmentedControl) {
        print("\(sender.selectedSegmentIndex)")
    }
}
