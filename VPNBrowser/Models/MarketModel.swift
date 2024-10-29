//
//  MarketModel.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/22.
//

import Combine
import Moya
import UIKit

class HomeViewModel: ObservableObject {
    @Published var marketModel = MarketModel()

    @Published var marketData: [MarketModel] = []
    /// 分享的地址
    @Published var shareUrl: String = ""
    /// 邀请人员头像
    @Published var visitorImages: [String] = []
    /// 是否展示底部弹框
    @Published var showShareBottomSheet = false
    /// 显示更多邀请
    @Published var showAllImages = false

    private var cancellables = Set<AnyCancellable>()

    init() {
        $showShareBottomSheet
            .dropFirst()
            .sink { [weak self] value in
                guard let self else { return }
                if value {
                    Util.topViewController().popup.bottomSheet {
                        let v = UIView(frame: CGRect(x: 0, y: 0, width: Util.deviceWidth, height: 260))
                        v.backgroundColor = .white
                        let leftButton = Button().then {
                            $0.title("扫码分享")
                            $0.backgroundColor(.red)
                            $0.cornerRadius(25)
                            $0.titleFont(.systemFont(ofSize: 16))
                            $0.titleColor(.white)
                            $0.tapAction = {
                                Util.topViewController().dismiss(animated: true)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                                    guard let self else { return }
                                    generaShareUrl(for: marketModel.id) { url in
                                        if let url, let image = Util.createQRCodeImage(content: url) {
                                            Util.topViewController().popup.dialog {
                                                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
                                                imageView.image = image
                                                return imageView
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        let rightButton = Button().then {
                            $0.title("分享链接")
                            $0.backgroundColor(.red)
                            $0.cornerRadius(25)
                            $0.titleFont(.systemFont(ofSize: 16))
                            $0.titleColor(.white)
                            $0.tapAction = {
                                Util.topViewController().dismiss(animated: true)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                                    guard let self else { return }
                                    shareAction()
                                }
                            }
                        }

                        v.addSubview(leftButton)
                        v.addSubview(rightButton)

                        let width = (v.width - 52) * 0.5

                        leftButton.snp.makeConstraints { make in
                            make.left.equalToSuperview().inset(16)
                            make.height.equalTo(50)
                            make.width.equalTo(width)
                            make.centerY.equalToSuperview()
                        }

                        rightButton.snp.makeConstraints { make in
                            make.right.equalToSuperview().inset(16)
                            make.height.equalTo(50)
                            make.width.equalTo(width)
                            make.centerY.equalToSuperview()
                        }

                        return v
                    }
                }
            }
            .store(in: &cancellables)
    }

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

                                // 如果 userType 是 [1]，且当前用户不是 visitor，则不展示
                                if model.userType == [1] && !LoginManager.shared.info.visitor {
                                    return false
                                }

                                return true
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
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            HUD.showTipMessage("返回数据为空,未能解析")
                        }
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

    /// 领取 活动 奖励
    func getMarketReward(id: String) {
        HUD.showLoading()
        APIProvider.shared.request(.getMarketReward(id: id)) { [weak self] result in
            HUD.hideNow()
            guard let self else { return }
            switch result {
            case .success:
                self.fetchMarketList()
            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }

    /// 查询用户信息
    func visitorAccess(id: String, index: Int) {
        APIProvider.shared.request(.visitorAccess(id: id), model: UserInfoModel.self) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(model):
                DispatchQueue.main.async {
                    if index < self.visitorImages.count {
                        self.visitorImages[index] = model.headPortrait ?? ""
                    }
                }
            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }

    func remainingInviteCount(for model: MarketModel) -> Int {
        let shareCount = model.template.details.shareUserCount
        let invitedCount = model.doInfo?.hasShareUserIds.count ?? 0
        return shareCount - invitedCount
    }

    func inviteStatus(for model: MarketModel) -> String {
        let remainingCount = remainingInviteCount(for: model)
        
        if remainingCount == 0 {
            return model.hasGet ? "已领取" : "领取"
        } else {
            return "再邀请\(remainingCount)人"
        }
    }


    func shareAction() {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }

            guard let shareURL = URL(string: shareUrl) else {
                return
            }

            var activityItems: [Any]
            if #available(iOS 17, *) {
                activityItems = [shareURL as Any]
            } else {
                activityItems = [CustomShareItem(shareURL: shareURL, shareText: Util.appName(), shareImage: UIImage.icon ?? .init()) as Any]
            }
            DispatchQueue.main.async {
                let vc = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
                vc.modalPresentationStyle = .fullScreen
                if let popoverController = vc.popoverPresentationController {
                    popoverController.sourceView = Util.topViewController().view
                    popoverController.sourceRect = CGRect(x: Util.topViewController().view.bounds.midX, y: Util.topViewController().view.bounds.midY, width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                }
                Util.topViewController().present(vc, animated: true, completion: nil)

                vc.completionWithItemsHandler = { _, _, _, _ in }
            }
        }
    }
}

class ResponseModel<T>: BaseModel {
    var data: [T]?
}

class MarketModel: BaseModel {
    var id: String = ""
    var template = TemplateInfo()
    var name: String = ""
    /// 是否领取
    var hasGet: Bool = false
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
    var details = TemplateDetails()
    // 限时时常/h
    var limitTime: Float?
    var rightsType: Int?
    var limitType: Int?

    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)

        mapper.specify(property: &details, name: "template")
    }
}

class TemplateDetails: BaseModel {
    // 需邀请人数
    var shareUserCount: Int = 0
    // 赠送天数
    var getDay: Int = 0
}

class DoInfo: BaseModel {
    // 已分享用户ID
    var hasShareUserIds: [String] = []
}
