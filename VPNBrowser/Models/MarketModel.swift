//
//  MarketModel.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/22.
//

import Moya
import UIKit

class HomeViewModel: ObservableObject {
    @Published var marketModel = MarketModel()
    @Published var marketData: [MarketModel] = []
    /// 分享的地址
    @Published var shareUrl: String = ""

    func fetchMarketList() {
        HUD.showLoading()
        APIProvider.shared.request(.marketList, progress: { _ in }) { [weak self] result in
            HUD.hideNow()
            guard let self = self else { return }
            switch result {
            case let .success(response):
                if !(200 ... 299).contains(response.statusCode) {
                    HUD.showTipMessage("Server Error: \(response.statusCode)")
                    print("Server Error: Status code \(response.statusCode), response body: \(String(describing: try? response.mapString()))")
                    return
                }

                if let responseString = try? response.mapString() {
                    print("Response JSON: \(responseString)")
                    if let marketResponse = ResponseModel<MarketModel>.deserialize(from: responseString) {
                        if let marketData = marketResponse.data, let model = marketData.first {
                            self.marketModel = model

                            let filteredData = marketData.filter { model in

                                let currentUserType = LoginManager.shared.info.userType

                                let userType = model.userType

                                // 如果 userType 是 [1]，且当前用户不是 visitor，则不展示
                                if userType == [1] && currentUserType != .visitor {
                                    return false
                                }

                                // 如果 userType 是 [2]，则 visitor 用户能展示，需要跳转到登录
                                if userType == [2] && currentUserType == .visitor {
                                    // 跳转到登录页面
                                    return true
                                }

                                // 如果 userType 包含 1 或者 2 都可以展示
                                return userType.contains(currentUserType.rawValue + 1)
                            }

                            if let firstModel = filteredData.first {
                                self.marketModel = firstModel
                                self.marketData = Array(filteredData.dropFirst())
                            } else {
                                self.marketData = []
                            }
                        }
                    } else {
                        print("Failed to parse response")
                    }
                }
            case let .failure(error):
                switch error {
                case let .jsonMapping(response):
                    HUD.showTipMessage("JSON mapping error: \(response)")
                    print("JSON mapping error: \(response)")
                case let .statusCode(response):
                    HUD.showTipMessage("Invalid status code: \(response.statusCode)")
                    print("Invalid status code: \(response.statusCode)")
                case let .underlying(nsError as NSError, _):
                    if nsError.domain == NSCocoaErrorDomain && nsError.code == 3840 {
                        HUD.showTipMessage("Unable to parse empty data.")
                        print("Unable to parse empty data.")
                    } else {
                        HUD.showTipMessage("Other NSError: \(nsError.localizedDescription)")
                        print("Other NSError: \(nsError.localizedDescription)")
                    }
                default:
                    HUD.showTipMessage("Moya error: \(error.localizedDescription)")
                    print("Moya error: \(error.localizedDescription)")
                }
            }
        }
    }

    func fetchMarketDetail(id: String) {
        HUD.showLoading()
        APIProvider.shared.request(.marketDetail(id: id), model: MarketModel.self) { [weak self] result in
            HUD.hideNow()
            guard let self else { return }
            switch result {
            case let .success(model):
                self.marketModel = model
            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }

    func generaShareUrl(for id: String, completion: @escaping (String?) -> Void) {
        if shareUrl.count > 0 {
            completion(shareUrl)
            return
        }

        HUD.showLoading()
        APIProvider.shared.request(.generaBrowserShareUrl(id: id), progress: { _ in }) { [weak self] result in
            HUD.hideNow()
            guard let self else { return }
            switch result {
            case let .success(response):
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: Any],
                       let shareUrl = jsonObject["data"] as? String {
                        self.shareUrl = shareUrl
                        completion(shareUrl) // 回调返回 shareUrl
                    } else {
                        HUD.showTipMessage("未能解析 'data' 字段")
                        print("未能解析 'data' 字段")
                        completion(nil) // 如果解析失败，回调返回 nil
                    }
                } catch {
                    HUD.showTipMessage("Failed to parse JSON: \(error)")
                    print("Failed to parse JSON: \(error)")
                    completion(nil) // 如果解析错误，回调返回 nil
                }
            case let .failure(error):
                HUD.showTipMessage("Request failed with error: \(error)")
                print("Request failed with error: \(error)")
                completion(nil) // 请求失败时，回调返回 nil
            }
        }
    }
}

class ResponseModel<T>: BaseModel {
    var data: [T]?
}

class MarketModel: BaseModel {
    var id: String = ""
    var template: TemplateInfo?
    var name: String = ""
    /// 是否领取
    var hasGet: Bool?
    /// 已经参与人数
    var hasJoinCount: Int = 0
    var startTime: Int64?
    /// 用户参与信息表,不同类型不同
    var doInfo: DoInfo?
    /// 1-游客 2-注册用户 3-vip用户
    var userType: [Int] = []
    var endTime: Int64?
    var userId: String?
    var marketType: Int?

    override func mapping(mapper: HelpingMapper) {
        mapper <<< id <-- TransformOf<String, Int64>(fromJSON: { (value: Int64?) -> String in
            value.map { String($0) } ?? ""
        }, toJSON: { (value: String?) -> Int64 in
            value.flatMap { Int64($0) } ?? 0
        })
    }
}

class TemplateInfo: BaseModel {
    var template: TemplateDetails?
    // 限时时常/h
    var limitTime: Float?
    var rightsType: Int?
    var limitType: Int?
}

class TemplateDetails: BaseModel {
    // 需邀请人数
    var shareUserCount: Int = 0
    // 赠送天数
    var getDay: Int = 0
}

class DoInfo: BaseModel {
    // 已分享用户ID
    var hasShareUserIds: [String]?
    // 限时到期日期
    var expireTime: String?
}
