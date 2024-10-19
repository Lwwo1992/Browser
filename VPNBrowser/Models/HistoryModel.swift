//
//  HistoryModel.swift
//  VPNBrowser
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
                recordData = DBaseManager.share.qureyFromDb(
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
}

class HistoryModel: BaseModel, TableCodable, ObservableObject {
    var id = UUID().uuidString
    var parentId = ""
    var name = ""
    var address: String?
    var title: String?
    var pageLogo: String?
    var imagePath: String?
    var timestamp: TimeInterval = Date().timeIntervalSince1970
    @Published var isSelected = false

    var url: URL {
        guard let imagePath = imagePath else {
            return S.Files.imageURL
        }
        return S.Files.imageURL.appendingPathComponent(imagePath)
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
    }
}
