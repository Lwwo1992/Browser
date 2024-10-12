//
//  ViewController.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/8.
//

@_exported import SwiftUI
import UIKit

class ViewController: UIViewController {
    var rootView: AnyView? { nil }

    var hostingController: UIHostingController<AnyView>?

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
}

extension ViewController {
    @objc func initUI() {
        if let rootView = rootView {
            setupHostingController(rootView: rootView)
        }

        view.backgroundColor = UIColor(hex: 0xF8F5F5)
    }

    private func setupHostingController<Content: View>(rootView: Content) {
        let hosting = UIHostingController(rootView: AnyView(rootView))
        hosting.view.backgroundColor = .clear
        hostingController = hosting

        addChild(hosting)
        view.addSubview(hosting.view)

        hosting.view.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }

        hosting.didMove(toParent: self)
    }
}
