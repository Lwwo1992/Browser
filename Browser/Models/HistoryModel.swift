//
//  HistoryModel.swift
//  Browser
//
//  Created by xyxy on 2024/10/14.
//

import Combine
import UIKit

class HistoryViewModel: ObservableObject {
    @Published var selectedSegmentIndex: Int = 0
    @Published var recordData: [HistoryModel] = []
    @Published var selectedArray: [HistoryModel] = []
    /// 文件夹数据
    @Published var folderData: [FolderModel] = []
    @Published var selectedFolderArray: [FolderModel] = []
    @Published var showingAllDeleteAlert = false
    @Published var showingDeleteAlert = false
    @Published var showingTextFieldAlert = false
    @Published var isEdit = false

    var isAllSelected: Bool {
        return selectedArray.count == recordData.count
    }

    var isAllFolderSelected: Bool {
        return selectedFolderArray.count == folderData.count
    }

    private var cancellables = Set<AnyCancellable>()

    func loadFolderData() {
        if let array = DBaseManager.share.qureyFromDb(fromTable: S.Table.folder, cls: FolderModel.self) {
            folderData = array.reversed()
        }
        loadHistory()
    }

    func loadHistory() {
        if selectedSegmentIndex == 0 {
            folderData.forEach { model in
                let recordData = DBaseManager.share.qureyFromDb(
                    fromTable: S.Table.collect,
                    cls: HistoryModel.self,
                    where: HistoryModel.Properties.parentId == model.id
                )?.reversed() ?? []
                model.children = recordData
            }
        }

        recordData = DBaseManager.share.qureyFromDb(
            fromTable: selectedSegmentIndex == 0 ? S.Table.collect : S.Table.browseHistory,
            cls: HistoryModel.self,
            where: HistoryModel.Properties.parentId == ""
        )?.reversed() ?? []
    }

    func deleteRecords() {
        recordData.removeAll()
        DBaseManager.share.deleteFromDb(fromTable: selectedSegmentIndex == 0 ? S.Table.collect : S.Table.browseHistory)
    }

    func deleteRecord(_ model: HistoryModel) {
        if let index = recordData.firstIndex(where: { $0.id == model.id }) {
            recordData.remove(at: index)
            DBaseManager.share.deleteFromDb(
                fromTable: S.Table.browseHistory,
                where: HistoryModel.Properties.id == model.id
            )
        }
    }

    func updateSelectedArray(for model: HistoryModel) {
        if model.isSelected {
            selectedArray.append(model)
        } else {
            selectedArray.removeAll { $0.id == model.id }
        }
    }

    func deleteSelectedItems() {
        recordData.removeAll { model in
            if selectedArray.contains(where: { $0.id == model.id }) {
                DBaseManager.share.deleteFromDb(
                    fromTable: selectedSegmentIndex == 0 ? S.Table.collect : S.Table.browseHistory,
                    where: DownloadModel.Properties.id == model.id
                )
                return true
            }
            return false
        }

        selectedArray.removeAll()
    }

    func toggleSelectAll() {
        if selectedArray.count == recordData.count {
            selectedArray.removeAll()
            recordData.forEach { $0.isSelected = false }
        } else {
            recordData.forEach { $0.isSelected = true }
            selectedArray = recordData
        }
    }

    func deleteSelectedFolderItems() {
        folderData.removeAll { model in
            if selectedFolderArray.contains(where: { $0.id == model.id }) {
                DBaseManager.share.deleteFromDb(
                    fromTable: S.Table.folder,
                    where: DownloadModel.Properties.id == model.id
                )
                return true
            }
            return false
        }

        selectedFolderArray.removeAll()
    }

    func updateSelectedFolderArray(for model: FolderModel) {
        if model.isSelected {
            selectedFolderArray.append(model)
        } else {
            selectedFolderArray.removeAll { $0.id == model.id }
        }
    }

    func toggleSelectFolderAll() {
        if selectedFolderArray.count == folderData.count {
            selectedFolderArray.removeAll()
            folderData.forEach { $0.isSelected = false }
        } else {
            folderData.forEach { $0.isSelected = true }
            selectedFolderArray = folderData
        }
    }

    /// 同步数据
    func syncBookmark() {
        if LoginManager.shared.info.userType == .visitor || LoginManager.shared.info.token.isEmpty {
            Util.topViewController().navigationController?.pushViewController(LoginViewController(), animated: true)
            return
        }

        let parameters: [[String: Any]] = createRequestData(folderData: folderData, recordData: recordData)
        HUD.showLoading()
        APIProvider.shared.request(.syncBookmark(data: parameters)) { [weak self] result in
            guard let self else { return }
            HUD.hideNow()
            switch result {
            case .success:
                fetchBookmark()
                break
            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }

    private func createRequestData(folderData: [FolderModel], recordData: [HistoryModel]) -> [[String: Any]] {
        var dataArray: [[String: Any]] = []

        for folder in folderData {
            var folderDict: [String: Any] = [
                "name": folder.name,
                "accountId": LoginManager.shared.info.id,
            ]

            var childrenArray: [[String: Any?]] = []

            for child in folder.children {
                let childDict: [String: Any] = [
                    "name": child.name,
                    "address": child.address ?? "",
                    "accountId": LoginManager.shared.info.id,
                ]
                childrenArray.append(childDict)
            }

            folderDict["children"] = childrenArray
            dataArray.append(folderDict)
        }

        for record in recordData {
            let recordDict: [String: Any] = [
                "address": record.address ?? "",
                "name": record.name,
                "accountId": LoginManager.shared.info.id,
            ]
            dataArray.append(recordDict)
        }

        return dataArray
    }

    /// 获取书签列表
    private func fetchBookmark() {
        // 清空原有的数据库数据
        DBaseManager.share.deleteFromDb(fromTable: S.Table.folder)
        DBaseManager.share.deleteFromDb(fromTable: S.Table.collect)

        let dispatchGroup = DispatchGroup()

        // 首先发起主文件夹请求
        dispatchGroup.enter()
        APIProvider.shared.request(.bookmarkPage(), model: FolderModel.self) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(model):
                // 过滤出有地址的记录和无地址的文件夹
                self.recordData = model.record.filter { $0.address != nil }

                var folderData: [FolderModel] = []

                // 处理每个子文件夹
                for temp in model.record.filter({ $0.address == nil }) {
                    dispatchGroup.enter()
                    let folder = FolderModel()
                    folder.id = temp.id
                    folder.name = temp.name

                    // 获取子文件夹书签
                    self.fetchChildBookmarks(for: temp.id) { childData in
                        folder.children = childData
                        folderData.append(folder)
                        dispatchGroup.leave() // 子文件夹处理完毕
                    }
                }

                dispatchGroup.leave()

                dispatchGroup.notify(queue: .main) {
                    HUD.showTipMessage("数据同步成功")

                    self.folderData = folderData

                    for record in self.recordData {
                        if record.parentId == "0" {
                            record.parentId = ""
                        }
                    }
                    DBaseManager.share.insertToDb(objects: self.recordData, intoTable: S.Table.collect)
                    self.folderData.forEach { model in
                        DBaseManager.share.insertToDb(objects: model.children, intoTable: S.Table.collect)
                    }
                    DBaseManager.share.insertToDb(objects: folderData, intoTable: S.Table.folder)
                }

            case let .failure(error):
                print("Main bookmark request failed with error: \(error)")
                dispatchGroup.leave() // 主请求失败时也需要调用 leave
            }
        }

        // 所有请求完成后执行后续操作
        dispatchGroup.notify(queue: .main) {
            print("All bookmark requests have been completed.")
            // 在这里可以进行后续的处理，比如刷新 UI
        }
    }

    /// 获取子文件夹书签
    private func fetchChildBookmarks(for id: String, completion: @escaping ([HistoryModel]) -> Void) {
        APIProvider.shared.request(.bookmarkPage(id: id), model: FolderModel.self) { result in
            switch result {
            case let .success(model):
                // 将子文件夹的书签数据返回
                completion(model.record)
            case let .failure(error):
                print("Child bookmark request for folder ID \(id) failed with error: \(error)")
                completion([]) // 即使失败，也返回空数组，避免中断流程
            }
        }
    }
}

class HistoryModel: BaseModel, TableCodable, ObservableObject, NSCopying {
    var id = UUID().uuidString
    var parentId = ""
    var name = ""
    var address: String?
    var title: String?
    var pageLogo: String?
    var imagePath: String?
    var timestamp: TimeInterval = Date().timeIntervalSince1970
    var lastAccessed: Date?

    @Published var isSelected = false

    var url: URL {
        guard let imagePath = imagePath else {
            return S.Files.imageURL
        }
        return S.Files.imageURL.appendingPathComponent(imagePath)
    }

    func checkImageExists(at url: URL) -> Bool {
        guard FileManager.default.fileExists(atPath: url.path) else {
            return false
        }

        // 尝试初始化 UIImage，如果成功则说明是图片
        if let _ = UIImage(contentsOfFile: url.path) {
            return true
        } else {
            return false
        }
    }

    static func == (lhs: HistoryModel, rhs: HistoryModel) -> Bool {
        return lhs.id == rhs.id
    }

    enum CodingKeys: String, CodingTableKey {
        typealias Root = HistoryModel
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        case id
        case address
        case title
        case pageLogo
        case imagePath
        case timestamp
        case parentId
        case name
        case lastAccessed
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = HistoryModel()
        copy.parentId = parentId
        copy.name = name
        copy.address = address
        copy.title = title
        copy.pageLogo = pageLogo
        copy.imagePath = imagePath
        copy.timestamp = timestamp
        return copy
    }
}

extension HistoryModel {
    func estimatedSize() -> Int64 {
        // 计算各个属性的大小
        let idSize = Int64(id.utf8.count) // UUID字符串的大小
        let parentIdSize = Int64(parentId.utf8.count) // parentId的大小
        let nameSize = Int64(name.utf8.count) // name的大小
        let addressSize = address != nil ? Int64(address!.utf8.count) : 0 // address的大小
        let titleSize = title != nil ? Int64(title!.utf8.count) : 0 // title的大小
        let pageLogoSize = pageLogo != nil ? Int64(pageLogo!.utf8.count) : 0 // pageLogo的大小
        let imagePathSize = imagePath != nil ? Int64(imagePath!.utf8.count) : 0 // imagePath的大小
        let timestampSize = Int64(MemoryLayout<TimeInterval>.size) // timestamp的大小

        // 返回总大小
        return idSize + parentIdSize + nameSize + addressSize + titleSize + pageLogoSize + imagePathSize + timestampSize
    }
}
