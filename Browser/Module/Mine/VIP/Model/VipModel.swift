//
//  VipModel.swift
//  Browser
//
//  Created by xyxy on 2024/10/23.
//

import Foundation

class VipRight: BaseModel {
    var id: String?
    /// 权益模版
    var template: VipTemplate?
    /// 描述
    var des: String = ""
    /// 会员卡
    var vipCards: Any?
    /// 权益类型：1-免费上网
    var rightsType: Int?
    /// 图标
    var icon: String = ""
    /// 名称
    var name: String = ""
}

class VipTemplate: BaseModel {
    var day: Int?
}

class VipModel: BaseModel {
    var id: String = ""
    /// 有效期会员卡: 1-限时 2-永久
    var validType: Int = 0
    /// 原价
    var originalPrice: String = ""
    /// 有效开始时间
    var validStartTime: String?
    /// 折扣价
    var discountPrice: String?
    /// 过期时间,永久-1
    var vipExpireTime: String?
    /// 会员卡权益
    var vipRights: [VipRight]?
    /// 有效结束时间
    var validEndTime: String?
    /// 折扣结束时间
    var discountEndTime: Double?
    /// 折扣开始时间
    var discountStartTime: Double?
    /// 名称
    var name: String = ""
    /// 折扣类型: 1-不限时折扣 2-限时折扣
    var discountType: Int?
    /// 参加用户 1-游客 2-注册用户 3-vip用户
    var userType: [Int] = []
    /// 活动时间有效类型: 1-不限时 2-限时(自定义)
    var activityType: Int?
    /// 会员卡天数
    var day: Int = 0

    /// 计算支付价格
    var payPrice: String {
        let currentTime = Date().timeIntervalSince1970 * 1000 // 当前时间戳（毫秒）

        // 判断是否在折扣时间范围内
        if let discountStartTime = discountStartTime,
           let discountEndTime = discountEndTime,
           currentTime >= discountStartTime && currentTime <= discountEndTime,
           let discountPrice = discountPrice {
            return discountPrice
        } else {
            return originalPrice
        }
    }

    /// 判断是否有折扣
    var isDiscounted: Bool {
        let currentTime = Date().timeIntervalSince1970 * 1000

        return discountStartTime != nil && discountEndTime != nil &&
            currentTime >= discountStartTime! && currentTime <= discountEndTime!
    }
}

class VipResponse: BaseModel {
    var total: Int?
    var record: [VipModel]?
}
