//
//  AnonymousConfigModel.swift
//  Browser
//
//  Created by xyxy on 2024/10/12.
//

import UIKit

class AnonymousConfigModel: BaseModel {
    var bucket: String?
    var uploadAddrPrefix: String?
    var endpoint: String?
    var bucketMap: [String: BucketInfo]?
    var secretKey: String?
    var accessKey: String?
    var prefix: String?
    var bucketAlias: String?
    var expiration: Int?
    var token: String?
}

struct BucketInfo: HandyJSON {
    var bucket: String?
    var videoUrl: String?
    var imageUrl: String?
}
