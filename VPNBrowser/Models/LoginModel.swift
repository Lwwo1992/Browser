//
//  LoginModel.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/12.
//

import UIKit

class LoginModel: BaseModel, TableCodable {
    var token: String?
    var memberKey: String?
    var account: String?

    enum CodingKeys: String, CodingTableKey {
        typealias Root = LoginModel
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        case token
        case memberKey
        case account
    }
}
