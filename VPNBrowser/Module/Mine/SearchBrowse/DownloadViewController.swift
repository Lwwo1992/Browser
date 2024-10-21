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
            .sink { _ in
                guard let components = NSURLComponents(url: S.Files.downloads, resolvingAgainstBaseURL: true) else {
                    return
                }
                
                components.scheme = "shareddocuments"

                if let sharedDocuments = components.url {
                    UIApplication.shared.open(
                        sharedDocuments,
                        options: [:],
                        completionHandler: nil
                    )
                }
            }
            .store(in: &cancellables)

        viewModel.$isEdit
            .dropFirst()
            .sink { [weak self] value in
                guard let self else { return }
                editButton.title(!value ? "编辑" : "删除")
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
        viewModel.isEdit.toggle()
        if viewModel.isEdit == false && !viewModel.selectedArray.isEmpty {
            showDeleteConfirmation()
        }
    }

    private func showDeleteConfirmation() {
        let alert = UIAlertController(
            title: "确认删除",
            message: "您确定要删除选中的项目吗？",
            preferredStyle: .alert
        )

        let deleteAction = UIAlertAction(title: "删除", style: .destructive) { _ in
            self.viewModel.deleteSelectedItems()
        }

        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }
}
