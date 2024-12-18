//
//  VipViewModel.swift
//  Browser
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
//        HUD.showLoading()
        APIProvider.shared.request(.visitorAccessPage, model: VipResponse.self) { [weak self] result in
            guard let self else { return }
//            HUD.hideNow()
            switch result {
            case let .success(response):
                if let record = response.record {
//                    let vipCards = record.filter { model in
//
//                        let curType = LoginManager.shared.info.userType
//
//                        let userType = model.userType
//
//                        // 如果 userType 是 [2]，则 visitor 用户能展示，需要跳转到登录
//                        if userType == [2] && curType == .visitor {
//                            return true
//                        }
//
//                        // 如果 userType 包含 1 或者 2 都可以展示
//                        return userType.contains(curType.rawValue)
//                    }
                    self.vipCards = makeCardList(record)
                    if let firstItem = self.vipCards.first {
                        selectedItem = firstItem
                    }
                }
            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }

    func makeCardList(_ list: [VipModel]?) -> [VipModel] {
        let curType = LoginManager.shared.info.userType
        var newList = [VipModel]()

        list?.forEach { record in
            if record.userType.isEmpty {
            } else if record.userType.contains(3) {
                if curType.rawValue == 3 {
                    newList.append(record)
                } else if curType.rawValue == 2 {
                    if record.userType.contains(2) {
                        newList.append(record)
                    }
                } else {
                    if record.userType.contains(1) || record.userType.contains(2) {
                        newList.append(record)
                    }
                }
            } else if record.userType.contains(2) {
                newList.append(record)
            } else {
                if !LoginManager.shared.info.token.isEmpty {
                } else {
                    if curType.rawValue != 2 {
                        newList.append(record)
                    }
                }
            }
        }

        return newList
    }

    func pay() {
        if LoginManager.shared.info.token.isEmpty && LoginManager.shared.info.userType == .vipUser
            && selectedItem.userType.contains(3) {
            goPay()
        } else if LoginManager.shared.info.token.isEmpty && !selectedItem.userType.contains(1) {
            Util.topViewController().navigationController?.pushViewController(LoginViewController(), animated: true)
        } else {
            goPay()
        }
    }

    private func goPay() {
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
