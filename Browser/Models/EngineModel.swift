//
//  EngineModel.swift
//  Browser
//
//  Created by xyxy on 2024/10/12.
//

import UIKit

class EngineModel: BaseModel {
    var record: [RecordModel]?
}

class RecordModel: BaseModel {
    var name: String?
    var logo: String?
    var address: String?
    var keyword: String?
    var defaulted: Int?
}
