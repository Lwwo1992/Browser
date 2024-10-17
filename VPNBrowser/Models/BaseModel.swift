//
//  BaseModel.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/12.
//

import HandyJSON
import UIKit

class BaseModel: NSObject, HandyJSON {
    override required init() { }

    
    
    func mapping(mapper: HelpingMapper) {
    }
}

@objcMembers
class BaseResponse<T: HandyJSON>: NSObject, HandyJSON {
    var success: Bool?
    var timestamp: Int?
    var fileDomain: String?
    var ossInfo: String?
    var code: String?
    var message: String?
    var messageType: String?
    var data: T? // 泛型类型的数据

    override required init() { }
}
