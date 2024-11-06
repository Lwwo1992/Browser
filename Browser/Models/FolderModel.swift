//
//  FolderModel.swift
//  Browser
//
//  Created by xyxy on 2024/10/18.
//

import UIKit

class FolderModel: BaseModel, TableCodable, ObservableObject {
    var id = ""
    var name: String = ""
    var children: [HistoryModel] = []
    var record: [HistoryModel] = []
    @Published var isSelected = false

    enum CodingKeys: String, CodingTableKey {
        typealias Root = FolderModel
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        case id
        case name
        case children
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        let bookmarksData = try JSONEncoder().encode(children)
        let bookmarksString = String(data: bookmarksData, encoding: .utf8)
        try container.encode(bookmarksString, forKey: .children)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        if let bookmarksString = try? container.decode(String.self, forKey: .children),
           let bookmarksData = bookmarksString.data(using: .utf8) {
            children = (try? JSONDecoder().decode([HistoryModel].self, from: bookmarksData)) ?? []
        }
    }

    
    required init() {}
}
