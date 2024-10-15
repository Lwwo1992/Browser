//
//  BrowserViewController.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/8.
//

import UIKit

class BrowserViewController: ViewController {
    override var rootView: AnyView? {
        return AnyView(BrowserView())
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

extension BrowserViewController {
    override func initUI() {
        super.initUI()

        APIProvider.shared.request(.guideLabelPage) { result in
            switch result {
            case let .success:
                break
            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }
}
