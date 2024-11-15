//
//  SearchViewController.swift
//  Browser
//
//  Created by xyxy on 2024/10/10.
//

import Combine
import Kingfisher
import UIKit

class RecordStore: ObservableObject {
    @Published var records: [RecordModel] = []

    @Published var content: String = ""
    
    @Published var selectedEngine = RecordModel()
}

class SearchViewController: ViewController {
    private var recordStore = RecordStore()

    private var cancellables = Set<AnyCancellable>()

    private var selectedRecord: RecordModel? {
        didSet {
            guard let record = selectedRecord else {
                return
            }
            
            recordStore.selectedEngine = record

            let imageUrl = Util.getImageUrl(from: record.logo)
            (selctedButton.subviews.first as? UIImageView)?.setImage(with: imageUrl)
        }
    }

    // 用于记录下拉框是否显示
    private var isDropdownVisible = false

    override var rootView: AnyView? {
        return AnyView(SearchView(recordStore: recordStore))
    }

    private lazy var textField = TextField().then {
        $0.placeholder = "搜索"
        $0.font = .systemFont(ofSize: 14)
        $0.clearButtonMode = .whileEditing
    }

    private lazy var selctedButton = UIView().then { view in
        let imageView = UIImageView()
        let arrow = UIImageView().then {
            $0.image = UIImage(resource: .arrowBottom)
        }

        view.addSubview(imageView)
        view.addSubview(arrow)

        imageView.snp.makeConstraints { make in
            make.size.equalTo(15)
            make.left.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
        }

        arrow.snp.makeConstraints { make in
            make.size.equalTo(10)
            make.left.equalTo(imageView.snp.right).offset(2)
            make.centerY.equalToSuperview()
        }

        // 添加点击手势，展示下拉列表
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleDropdown))
        view.addGestureRecognizer(tapGesture)
    }

    // 下拉列表，用 UITableView 实现
    private lazy var dropdownTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.borderWidth = 1
        tableView.layer.cornerRadius = 5
        tableView.layer.borderColor = UIColor.gray.cgColor
        tableView.isHidden = true
        tableView.register(DropdownCell.self, forCellReuseIdentifier: DropdownCell.reuseIdentifier)
        return tableView
    }()

    private lazy var searchBarView = UIView().then { view in
        view.layer.cornerRadius = 17
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false

        [selctedButton, textField].forEach {
            view.addSubview($0)
        }

        selctedButton.frame = CGRect(x: 0, y: 0, width: 40, height: 35)
        textField.frame = CGRect(x: selctedButton.right, y: 0, width: Util.deviceWidth - 160, height: 35)
    }

    private lazy var goToButton = Button().then {
        $0.title("前往")
            .titleFont(.systemFont(ofSize: 14))
            .titleColor(.black)
            .tapAction = { [weak self] in
                guard let self else { return }
                guard let text = textField.text, text.count > 0 else {
                    HUD.showTipMessage("未搜索内容")
                    return
                }

                saveInfo(text)

                if let record = selectedRecord, let address = record.address, let keyword = record.keyword {
                    let vc = WebViewController()
                    vc.path = address + "/" + keyword + text
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    HUD.showTipMessage("未选择引擎")
                }
            }
        $0.frame = CGRect(x: 0, y: 0, width: 50, height: 35)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchRecords()

        recordStore.$content
            .dropFirst()
            .sink { [weak self] content in
                guard let self else { return }
                self.textField.text = content
            }
            .store(in: &cancellables)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }
}

extension SearchViewController {
    override func initUI() {
        super.initUI()

        navigationItem.titleView = searchBarView
        NSLayoutConstraint.activate([
            searchBarView.widthAnchor.constraint(equalToConstant: Util.deviceWidth - 120),
            searchBarView.heightAnchor.constraint(equalToConstant: 35),
        ])

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: goToButton)

        view.addSubview(dropdownTableView)
        dropdownTableView.frame = CGRect(x: 16, y: view.safeTop + 60, width: 150, height: 200)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutsideDropdown(_:)))
        tapGesture.cancelsTouchesInView = false // 让视图其他元素正常响应点击事件
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func toggleDropdown() {
        isDropdownVisible.toggle()
        dropdownTableView.isHidden = !isDropdownVisible
    }

    private func fetchRecords() {
        HUD.showLoading()
        APIProvider.shared.request(.enginePage, model: EngineModel.self) { [weak self] result in
            HUD.hideNow()
            guard let self = self else { return }
            switch result {
            case let .success(model):
                self.recordStore.records = model.record ?? []
                self.dropdownTableView.reloadData()

                if let defaultedRecord = self.recordStore.records.first(where: { $0.defaulted == 1 }) {
                    self.selectedRecord = defaultedRecord

                } else if let firstRecord = self.recordStore.records.first {
                    self.selectedRecord = firstRecord
                }

            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }

    @objc private func handleTapOutsideDropdown(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if !dropdownTableView.frame.contains(location) && isDropdownVisible {
            toggleDropdown()
        }

        textField.resignFirstResponder()
    }

    private func saveInfo(_ title: String) {
        if S.Config.openNoTrace {
            return
        }

        let model = HistoryModel()
        model.title = title

        if let existingModel = DBaseManager.share.qureyFromDb(fromTable: S.Table.searchHistory, cls: HistoryModel.self, where: HistoryModel.Properties.title == title)?.first {
            DBaseManager.share.updateToDb(
                table: S.Table.searchHistory,
                on: [HistoryModel.Properties.timestamp],
                with: model,
                where: HistoryModel.Properties.id == existingModel.id
            )
        } else {
            DBaseManager.share.insertToDb(
                objects: [model],
                intoTable: S.Table.searchHistory
            )
        }

        let currentRecords = DBaseManager.share.qureyFromDb(fromTable: S.Table.searchHistory, cls: HistoryModel.self)

        if currentRecords?.count ?? 0 > 20 {
            if let lastRecord = currentRecords?.last {
                DBaseManager.share.deleteFromDb(fromTable: S.Table.searchHistory, where: HistoryModel.Properties.id == lastRecord.id)
            }
        }
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordStore.records.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DropdownCell.reuseIdentifier, for: indexPath) as? DropdownCell else {
            return UITableViewCell()
        }

        let record = recordStore.records[indexPath.row]
        cell.configure(with: record)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRecord = recordStore.records[indexPath.row]

        toggleDropdown()
    }
}
