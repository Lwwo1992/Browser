//
//  LoginModel.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/12.
//

import UIKit

class LoginModel: BaseModel, TableCodable {
    var token: String = ""
    var vistoken: String = ""
    var memberKey: String?
    var account: String?
    var mobile = ""
    var mailbox = ""
    var userHead = ""
    var id = ""
    var logintype = "0"//0：游客 1用户
    
    ///查询用户信息
    var bookmarkNum = ""
    var createBy = ""
    var createTime = ""
    var deviceId = ""
    var gender = ""
    var headPortrait = ""
    var name: String?
    var state = ""
    var updateBy = ""
    var updateTime = ""
    var vipCardVO:vipCardVOModel = vipCardVOModel()
    var visitor = ""

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
        case state
        case updateBy
        case updateTime
        case visitor
        case logintype
        case id
    }
}


class UpdateHeadInfo:BaseModel{
    var bucket = ""
    var uploadAddrPrefix = ""
    var endpoint = ""
    var bucketMap = ""
    var secretKey = ""
    var accessKey = ""
    var token = ""
    var guide = guideModel()
}

class guideModel:BaseModel{
    var bucket = ""
    var videoUrl = ""
    var imageUrl = ""
}


 
class vipCardVOModel:BaseModel{
    
    
    var activityType = ""
    var createBy = ""
    var createTime = ""
    var day = ""
    var discountEndTime = ""
    var discountPrice = ""
    var discountStartTime = ""
    var discountType = ""
    var name = ""
    var state = ""
    var updateBy = ""
    var updateTime = ""
    var userType = ""
    var validEndTime = ""
    var validStartTime = ""
    var validType = ""
    var vipExpireTime = ""
    var vipRights:vipRightsModel = vipRightsModel() ///会员卡权益
}


class vipRightsModel:BaseModel{
    
    var createBy = ""
    var createTime = ""
    var des = ""
    var icon = ""
    var name = ""
    var rightsType = ""
    var state = ""
    var template = ""
    var updateBy = ""
    var updateTime = ""
    var vipCards = ""
    
}
