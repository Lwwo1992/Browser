//
//  GuideModel.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/15.
//

import UIKit

class GuideItem: BaseModel {
    var id: String?
    var name: String?
    var icon: String?
    var downloadUrl: String?
    var type: String?

    override required init() {}
}

// 用于表示返回的数据结构
class GuideResponse: BaseModel {
    var msg: String?
    var code: String?
    var name: String?
    var data: [GuideItem]?

    override required init() {}
}


