//
//  MoreGuideViewController.swift
//  Browser
//
//  Created by xyxy on 2024/10/15.
//

import UIKit

class MoreGuideViewController: ViewController {
    var guideResponse = GuideResponse()

    override var rootView: AnyView? {
        return AnyView(MoreGuideView(guideResponse: guideResponse))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension MoreGuideViewController {
    override func initUI() {
        super.initUI()
        title = guideResponse.name
    }
}
