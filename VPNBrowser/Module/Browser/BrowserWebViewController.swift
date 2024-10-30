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
                view.shareAction = { [weak self] in
                    guard let self else { return }
                    shareAction()
                }
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

    private func shareAction() {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }

            guard let shareURL = URL(string: viewModel.urlString) else {
                HUD.showTipMessage("不存在分享内容")
                return
            }

            var activityItems: [Any]
            if #available(iOS 17, *) {
                activityItems = [shareURL as Any]
            } else {
                activityItems = [CustomShareItem(shareURL: shareURL, shareText: Util.appName(), shareImage: UIImage.icon ?? .init()) as Any]
            }
            DispatchQueue.main.async {
                let vc = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
                vc.modalPresentationStyle = .fullScreen
                if let popoverController = vc.popoverPresentationController {
                    popoverController.sourceView = Util.topViewController().view
                    popoverController.sourceRect = CGRect(x: Util.topViewController().view.bounds.midX, y: Util.topViewController().view.bounds.midY, width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                }
                Util.topViewController().present(vc, animated: true, completion: nil)

                vc.completionWithItemsHandler = { _, _, _, _ in }
            }
        }
    }
}
