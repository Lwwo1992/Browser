//
//  UserGuideModel.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/16.
//

import UIKit

class UserGuideResponse: BaseModel, Identifiable {
    var title: String?
    var record: [UserGuideModel]?

    convenience init(title: String? = nil, record: [UserGuideModel]? = nil) {
        self.init()
        self.title = title
        self.record = record
    }
}

class UserGuideModel: BaseModel {
    var id: String?
    var icon: String?
    var title: String?
    var content: String?
    var subtitle: String?
    var classifyName: String?
}
