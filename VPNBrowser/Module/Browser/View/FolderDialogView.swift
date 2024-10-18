//
//  FolderDialogView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/18.
//

import UIKit

class FolderDialogView: UIView {
    var array: [FolderModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    var onFolderSelected: ((FolderModel?) -> Void)?

    private let tableView = UITableView()
    private var selectedIndexPath: IndexPath?

    private let cancelButton = UIButton(type: .system)
    private let confirmButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.cornerRadius = 10

        setupTableView()
        setupButtons()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-50)
        }
    }

    private func setupButtons() {
        cancelButton.setTitle("取消", for: .normal)
        confirmButton.setTitle("确定", for: .normal)

        cancelButton.setTitleColor(.red, for: .normal)
        confirmButton.setTitleColor(.blue, for: .normal)

        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)

        let buttonStackView = UIStackView(arrangedSubviews: [cancelButton, confirmButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 16
        buttonStackView.distribution = .fillEqually

        addSubview(buttonStackView)

        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(50) // 按钮高度
        }
    }

    @objc private func cancelButtonTapped() {
        Util.topViewController().dismiss(animated: true)
    }

    @objc private func confirmButtonTapped() {
        Util.topViewController().dismiss(animated: true)

        if let selectedIndexPath = selectedIndexPath {
            let selectedFolder = array[selectedIndexPath.row]
            onFolderSelected?(selectedFolder)
        }
    }
}

extension FolderDialogView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let folder = array[indexPath.row]

        cell.textLabel?.text = folder.name

        cell.imageView?.image = UIImage(systemName: "folder")

        if indexPath == selectedIndexPath {
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = .systemBlue
        } else {
            cell.accessoryType = .none
            cell.textLabel?.textColor = .black
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedIndexPath != indexPath {
            selectedIndexPath = indexPath
            tableView.reloadData()
        }
    }
}
