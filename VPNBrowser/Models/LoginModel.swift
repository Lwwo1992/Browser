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
    var mobile = ""
    var mailbox = ""

    enum CodingKeys: String, CodingTableKey {
        typealias Root = LoginModel
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        case token
        case memberKey
        case account
        case mobile
        case mailbox
    }
}


class UpdateHeadInfo:BaseModel{
    var bucket = ""
    var uploadAddrPrefix = ""
    var endpoint = ""
    var bucketMap = ""
    var guide = guideModel()
}

class guideModel:BaseModel{
    var bucket = ""
    var videoUrl = ""
    var imageUrl = ""
}
