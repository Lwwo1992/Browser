//
//  DownloadModel.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/16.
//

import UIKit

class DownloadViewModel: ObservableObject {
    @Published var selectedFileUrl: URL = URL(fileURLWithPath: "")
    @Published var array: [DownloadModel] = []
    @Published var selectedArray: [DownloadModel] = []
    @Published var isEdit: Bool = false

    init() {
        loadData()
    }

    private func loadData() {
        if let array = DBaseManager.share.qureyFromDb(fromTable: S.Table.download, cls: DownloadModel.self) {
            self.array = array
        }
    }

    func updateSelectedArray(for model: DownloadModel) {
        if model.isSelected {
            selectedArray.append(model)
        } else {
            selectedArray.removeAll { $0.id == model.id }
        }
    }

    func deleteSelectedItems() {
        array.removeAll { model in
            if self.selectedArray.contains(where: { $0.id == model.id }) {
                DBaseManager.share.deleteFromDb(fromTable: S.Table.download, where: DownloadModel.Properties.id == model.id)
                return true
            }
            return false
        }

        selectedArray.removeAll()
    }
}

class DownloadModel: TableCodable, Identifiable, ObservableObject {
    var id = UUID().uuidString
    var logo: String = ""
    var title: String = ""
    var url = ""
    var size: Int64 = 0
    var timestamp: TimeInterval = Date().timeIntervalSince1970
    @Published var isSelected: Bool = false

    enum CodingKeys: String, CodingTableKey {
        typealias Root = DownloadModel
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        case id
        case logo
        case title
        case url
        case size
        case timestamp
    }
}
