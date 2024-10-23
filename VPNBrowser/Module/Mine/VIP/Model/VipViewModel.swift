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
                    self.vipCards = record
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
        if LoginManager.shared.info.userType == .visitor {
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
