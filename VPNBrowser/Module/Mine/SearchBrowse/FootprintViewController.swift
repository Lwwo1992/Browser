//
//  CollectViewController.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/9.
//

import UIKit

class FootprintViewModel: ObservableObject {
    @Published var selectedSegmentIndex = 0
}

class FootprintViewController: ViewController {
    private var footprintViewModel = FootprintViewModel()

    override var rootView: AnyView? {
        return AnyView(FootprintView(viewModel: footprintViewModel))
    }

    private lazy var segmentedControl = UISegmentedControl(items: ["收藏", "历史"]).then {
        $0.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    convenience init(selectedSegmentIndex: Int) {
        self.init(nibName: nil, bundle: nil)
        footprintViewModel.selectedSegmentIndex = selectedSegmentIndex
        segmentedControl.selectedSegmentIndex = selectedSegmentIndex
    }
}

extension FootprintViewController {
    override func initUI() {
        super.initUI()

        navigationItem.titleView = segmentedControl
    }

    @objc func segmentChanged(_ sender: UISegmentedControl) {
        footprintViewModel.selectedSegmentIndex = sender.selectedSegmentIndex
    }
}
