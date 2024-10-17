//
//  DownloadManagerViewController.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/16.
//

import Combine
import UIKit

class DownloadViewController: ViewController {
    private var viewModel = DownloadViewModel()
    private var cancellables = Set<AnyCancellable>()

    override var rootView: AnyView? {
        return AnyView(DownloadView(viewModel: viewModel))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.$selectedFileUrl
            .dropFirst()
            .sink { [weak self] fileUrl in
                guard let self else { return }
                let documentInteractionController = UIDocumentInteractionController(url: fileUrl)
                documentInteractionController.delegate = self
                documentInteractionController.presentPreview(animated: true)
            }
            .store(in: &cancellables)
    }
}

extension DownloadViewController {
    override func initUI() {
        super.initUI()
        title = "下载管理"
    }
}

extension DownloadViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}
