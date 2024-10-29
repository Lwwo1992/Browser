//
//  LoginModel.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/12.
//

import UIKit

enum UserType: Int, HandyJSONEnum {
    case visitor = 1
    case user
    case vipUser
}

class LoginModel: BaseModel, TableCodable {
    var token: String = ""
    var vistoken: String = ""
    var memberKey: String?
    var account: String?
    var mobile = ""
    var mailbox = ""
    var userHead = ""
    var createTime = ""
    var id = ""
    private var userTypeV: Int = 0
    var userType: UserType {
        get {
            return UserType(rawValue: userTypeV) ?? .visitor
        }
        set {
            userTypeV = newValue.rawValue
        }
    }

    /// 查询用户信息
    var bookmarkNum = ""
    var createBy = ""
    var deviceId = ""
    var gender = ""
    var headPortrait = ""
    var name: String?
    /// vip购买信息
    var vipCardVO: [vipCardVOModel]?
    /// 是否为游客
    var visitor: Bool = true
    /// 是否 已经 购买 会员
    var isVIP: Bool {
        return vipCardVO?.isEmpty == false
    }

    enum CodingKeys: String, CodingTableKey {
        typealias Root = LoginModel
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        case token
        case vistoken
        case memberKey
        case account
        case mobile
        case mailbox
        case bookmarkNum
        case createBy
        case createTime
        case deviceId
        case gender
        case headPortrait
        case name
        case visitor
        case userTypeV
        case id
    }
}

class UpdateHeadInfo: BaseModel {
    var bucket = ""
    var uploadAddrPrefix = ""
    var endpoint = ""
    var bucketMap = ""
    var secretKey = ""
    var accessKey = ""
    var token = ""
    var guide = guideModel()
}

class guideModel: BaseModel {
    var bucket = ""
    var videoUrl = ""
    var imageUrl = ""
}

class vipCardVOModel: BaseModel {
    var activityType = ""
    var createBy = ""
    var createTime = ""
    var day = ""
    var discountEndTime = ""
    var discountPrice = ""
    var discountStartTime = ""
    var discountType = ""
    var name = ""
    var userType = ""
    var validEndTime = ""
    var validStartTime = ""
    var validType = 0
    var vipExpireTime: TimeInterval?
    var vipRights: vipRightsModel = vipRightsModel() /// 会员卡权益
}

class vipRightsModel: BaseModel {
    var createBy = ""
    var des = ""
    var icon = ""
    var name = ""
    var rightsType = ""
    var state = ""
    var template = ""
    var vipCards = ""
}
