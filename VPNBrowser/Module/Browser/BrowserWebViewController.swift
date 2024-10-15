//
//  WebViewController.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/14.
//

import Combine
import UIKit
import WebKit

class BrowserWebViewController: ViewController {
    var path: String = ""
    var viewModel = WebViewViewModel()

    private var cancellables = Set<AnyCancellable>()

    override var rootView: AnyView? {
        viewModel.urlString = path
        return AnyView(BrowserWebView(viewModel: viewModel))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.$showBottomSheet
            .dropFirst()
            .sink { [weak self] _ in
                guard let self else { return }
                let view = BrowserWebBottomSheet(frame: CGRect(x: 0, y: 0, width: Util.deviceWidth, height: 200))
                view.tf_showSlide(self.view, direction: .bottom, popupParam: TFPopupParam())
            }
            .store(in: &cancellables)
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
