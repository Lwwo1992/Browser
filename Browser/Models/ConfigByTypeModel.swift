//
//  ApiResponse.swift
//  Browser
//
//  Created by xyxy on 2024/10/11.
//

import Foundation
import HandyJSON
import WCDBSwift

class ConfigByTypeModel: HandyJSON {
    var data: ConfigModel?
    var content: String?

    required init() {}
}

class ConfigModel: HandyJSON, TableCodable {
    var maxAppNum: Int?
    var defalutUrl: String?
    var loginType: [LoginType]?

    enum CodingKeys: String, CodingTableKey {
        typealias Root = ConfigModel
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        case loginType
        case maxAppNum
        case defalutUrl
    }

    required init() {}

    func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &defalutUrl, name: "defalutUrl")
    }
}

class LoginType: HandyJSON, TableCodable {
    var key: String?
    var label: String?
    var value: Bool?

    enum CodingKeys: String, CodingTableKey {
        typealias Root = LoginType
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        case key
        case label
        case value
    }

    required init() {}
}
