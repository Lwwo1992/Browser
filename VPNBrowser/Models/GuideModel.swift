//
//  GuideModel.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/15.
//

import UIKit

class GuideItem: BaseModel, Identifiable {
    var id: String?
    var name: String?
    var icon: String?
    var downloadUrl: String?
    var type: String?
}

// 用于表示返回的数据结构
class GuideResponse: BaseModel, Identifiable {
    var name: String?
    var appIcon: String?
    var data: [GuideItem]?
}
