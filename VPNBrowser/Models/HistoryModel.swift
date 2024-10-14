//
//  HistoryModel.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/14.
//

import UIKit

class HistoryModel: TableCodable, Hashable {
    var id = UUID().uuidString
    var path: String?
    var title: String?
    var pageLogo: String?
    var timestamp: TimeInterval = Date().timeIntervalSince1970

    static func == (lhs: HistoryModel, rhs: HistoryModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    enum CodingKeys: String, CodingTableKey {
        typealias Root = HistoryModel
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        case id
        case path
        case title
        case pageLogo
        case timestamp
    }
}
