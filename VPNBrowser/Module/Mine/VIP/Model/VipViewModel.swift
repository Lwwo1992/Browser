//
//  VipViewModel.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/23.
//

import UIKit

class VipViewModel: ObservableObject {
    @Published var vipCards: [VipModel] = []
    @Published var selectedItem = VipModel() {
        didSet {
            currentPrice()
        }
    }

    @Published var payPrice = ""

    func fetchVipCardPage() {
        HUD.showLoading()
        APIProvider.shared.request(.visitorAccessPage, model: VipResponse.self) { [weak self] result in
            guard let self else { return }
            HUD.hideNow()
            switch result {
            case let .success(response):
                if let record = response.record {
                    let vipCards = record.filter { model in

                        let currentUserType = LoginManager.shared.info.userType

                        let userType = model.userType

                        // 如果 userType 是 [1]，且当前用户不是 visitor，则不展示
                        if userType == [1] && currentUserType != .visitor {
                            return false
                        }

                        if userType == [3] && currentUserType == .vipUser && !LoginManager.shared.info.token.isEmpty {
                            return true
                        }

                        // 如果 userType 是 [2]，则 visitor 用户能展示，需要跳转到登录
                        if userType == [2] && (currentUserType == .visitor || LoginManager.shared.info.token.isEmpty) {
                            // 跳转到登录页面
                            return true
                        }

                        // 如果 userType 包含 1 或者 2 都可以展示
                        return userType.contains(currentUserType.rawValue + 1)
                    }
                    self.vipCards = vipCards
                    if let firstItem = self.vipCards.first {
                        selectedItem = firstItem
                    }
                }
            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }

    func pay() {
        if !selectedItem.userType.contains(1) && LoginManager.shared.info.token.isEmpty {
            Util.topViewController().navigationController?.pushViewController(LoginViewController(), animated: true)
        } else {
            HUD.showLoading()
            APIProvider.shared.request(.userBuyVip(id: selectedItem.id)) { result in
                HUD.hideNow()
                switch result {
                case .success:
                    HUD.showTipMessage("购买成功")

                    LoginManager.shared.fetchUserInfo()
                case let .failure(error):
                    print("Request failed with error: \(error)")
                }
            }
        }
    }

    func currentPrice() {
        let currentTime = Date().timeIntervalSince1970 * 1000

        if let discountStartTime = selectedItem.discountStartTime,
           let discountEndTime = selectedItem.discountEndTime,
           currentTime >= discountStartTime && currentTime <= discountEndTime {
            payPrice = selectedItem.discountPrice ?? selectedItem.originalPrice
        } else {
            payPrice = selectedItem.originalPrice
        }
    }
}
