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

    private lazy var editButton = Button().then {
        $0.title("编辑")
            .titleFont(.systemFont(ofSize: 14))
            .tapAction = { [weak self] in
                guard let self else { return }
                self.editAction()
            }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.$selectedFileUrl
            .dropFirst()
            .sink { fileUrl in
                guard var components = URLComponents(url: fileUrl, resolvingAgainstBaseURL: false) else { return }

                components.scheme = "shareddocuments"

                guard let newURL = components.url else { return }

                if UIApplication.shared.canOpenURL(newURL) {
                    UIApplication.shared.open(newURL)
                }
            }
            .store(in: &cancellables)
    }
}

extension DownloadViewController {
    override func initUI() {
        super.initUI()
        title = "下载管理"

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editButton)
    }

    private func editAction() {
        
    }
}
