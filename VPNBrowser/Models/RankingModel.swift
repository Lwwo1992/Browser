//
//  RankingModel.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/14.
//

import UIKit

class RecordRankingModel: BaseModel {
    var record: [RankingModel]?
}

class RankingModel: BaseModel {
    /// 关键字参数
    var keyword: String?
    /// 真实排名
    var trueRanking: Int?
    /// 虚假排名
    var falseRanking: Int?
    /// 搜索指数
    var searchIndex: String?
    /// 搜索指数
    var marker: String?

    var formattedSearchIndex: String {
        guard let searchIndex = Double(searchIndex ?? "0") else { return "无" }

        switch searchIndex {
        case 0 ..< 1000:
            return String(format: "%.1f", searchIndex)
        case 1000 ..< 10000:
            return String(format: "%.1fk", searchIndex / 1000)
        default:
            return String(format: "%.1fw", searchIndex / 10000)
        }
    }
}
