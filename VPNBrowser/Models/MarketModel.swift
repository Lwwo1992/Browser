//
//  MarketModel.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/22.
//

import UIKit

class HomeViewModel: ObservableObject {
    @Published var marketModel = MarketModel()
    @Published var marketData: [MarketModel] = []

    func fetchMarketList() {
        HUD.showLoading()
        APIProvider.shared.request(.marketList, progress: { _ in

        }) { [weak self] result in
            HUD.hideNow()
            guard let self = self else { return }
            switch result {
            case let .success(response):
                if let responseString = try? response.mapString() {
                    if let marketResponse = ResponseModel<MarketModel>.deserialize(from: responseString) {
                        if let marketData = marketResponse.data, let model = marketData.first {
                            self.marketModel = model
                            if marketData.count > 1 {
                                self.marketData = Array(marketData.dropFirst())
                            } else {
                                self.marketData = []
                            }
                        }
                    } else {
                        print("Failed to parse response")
                    }
                }
            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }

    func fetchMarketDetail() {
        APIProvider.shared.request(.marketDetail) { result in
            switch result {
            case let .success(model):
                break
            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }
}

class ResponseModel<T>: BaseModel {
    var data: [T]?
}

class MarketModel: BaseModel {
    var template: TemplateInfo?
    var name: String = ""
    var hasGet: Bool?
    var hasJoinCount: Int = 0
    var startTime: Int64?
    var doInfo: String?
    var id: Int64?
    var userType: [Int]?
    var endTime: Int64?
    var userId: String?
    var marketType: Int?
}

class TemplateInfo: BaseModel {
    var template: TemplateDetails?
    var limitTime: String?
    var rightsType: Int?
    var limitType: Int?
}

class TemplateDetails: BaseModel {
    var shareUserCount: Int?
    var getDay: Int?
}
