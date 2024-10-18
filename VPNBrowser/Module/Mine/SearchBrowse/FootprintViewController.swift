//
//  CollectViewController.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/9.
//

import Combine
import UIKit

class FootprintViewController: ViewController {
    private var viewModel = HistoryViewModel()

    private var cancellables = Set<AnyCancellable>()

    override var rootView: AnyView? {
        return AnyView(FootprintView(viewModel: viewModel))
    }

    private lazy var segmentedControl = UISegmentedControl(items: ["收藏", "历史"]).then {
        $0.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.$showingTextFieldAlert
            .dropFirst()
            .sink { [weak self] _ in
                guard let self else { return }
                self.showAlertWithTextField()
            }
            .store(in: &cancellables)
    }

    convenience init(selectedSegmentIndex: Int) {
        self.init(nibName: nil, bundle: nil)
        viewModel.selectedSegmentIndex = selectedSegmentIndex
        segmentedControl.selectedSegmentIndex = selectedSegmentIndex
    }
}

extension FootprintViewController {
    override func initUI() {
        super.initUI()

        navigationItem.titleView = segmentedControl
    }

    @objc func segmentChanged(_ sender: UISegmentedControl) {
        viewModel.selectedSegmentIndex = sender.selectedSegmentIndex
    }

    private func showAlertWithTextField() {
        let alertController = UIAlertController(title: "新建文件夹", message: "", preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "请输入文件夹名称"
        }

        let confirmAction = UIAlertAction(title: "确认", style: .default) { [weak self] _ in
            guard let self else { return }
            if let inputText = alertController.textFields?.first?.text {
                let model = FolderModel()
                model.name = inputText
                DBaseManager.share.insertToDb(objects: [model], intoTable: S.Table.folder)
                self.viewModel.loadFolderData()
            }
        }

        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)

        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
}
