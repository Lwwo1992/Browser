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
    @Published var isEdit: Bool = false

    init() {
        loadData()
    }

    private func loadData() {
        if let array = DBaseManager.share.qureyFromDb(fromTable: S.Table.download, cls: DownloadModel.self) {
            self.array = array
        }
    }
}

class DownloadModel: TableCodable, Identifiable {
    var id = UUID().uuidString
    var logo: String = ""
    var title: String = ""
    var url = ""
    var size: Int64 = 0
    var timestamp: TimeInterval = Date().timeIntervalSince1970
    var isSelected: Bool = false

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
