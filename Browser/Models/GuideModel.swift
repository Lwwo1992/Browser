//
//  GuideModel.swift
//  Browser
//
//  Created by xyxy on 2024/10/15.
//

import UIKit

class GuideViewModel: ObservableObject {
    @Published var guideSections: [GuideResponse] = []

    init() {
        guideConfig()
    }

    private func guideConfig() {
        APIProvider.shared.request(.guideConfig, model: AnonymousConfigModel.self) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(model):
                S.Config.guideAnonymous = model

                loadGuideLabels()

            case let .failure(error):
                print("请求失败: \(error)")
                HUD.showTipMessage(error.localizedDescription)
            }
        }
    }

    private func loadGuideLabels() {
        HUD.showLoading()
        APIProvider.shared.request(.guideLabelPage, progress: { _ in }) { [weak self] result in
            HUD.hideNow()
            guard let self else { return }
            switch result {
            case let .success(response):
                let jsonString = String(data: response.data, encoding: .utf8) ?? ""
                print("Response JSON: \(jsonString)")

                if let responseLabels = GuideResponse.deserialize(from: String(data: response.data, encoding: .utf8)) {
                    if let labels = responseLabels.data {
                        self.fetchApps(for: labels)
                    }
                }

            case let .failure(error):
                print("Error: \(error)")
            }
        }
    }

    private func fetchApps(for labels: [GuideItem]) {
        let group = DispatchGroup()
        var sections = Array(repeating: GuideResponse(), count: labels.count) 

        for (index, label) in labels.enumerated() {
            guard let id = label.id else { continue }
            group.enter()

            APIProvider.shared.request(.guideAppPage(labelID: id), progress: { _ in }) { result in
                switch result {
                case let .success(response):
                    let jsonString = String(data: response.data, encoding: .utf8) ?? ""
                    print("Response JSON: \(jsonString)")

                    if let responseApps = GuideResponse.deserialize(from: jsonString) {
                        let apps = responseApps.data ?? []

                        let section = GuideResponse()
                        section.data = apps
                        section.name = label.name
                        section.icon = label.icon
                        section.appIcon = label.appIcon

                        // 根据 label 原始顺序插入
                        sections[index] = section
                    } else {
                        print("Error decoding apps.")
                    }

                case let .failure(error):
                    print("Error: \(error)")
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.guideSections = sections
            HUD.hideNow()
        }
    }
}

class GuideItem: BaseModel {
    var id: String?
    var name: String?
    var icon: String?
    var appIcon: String?
    var downloadUrl: String?
    var type: String?
}

// 用于表示返回的数据结构
class GuideResponse: BaseModel {
    var name: String?
    var icon: String?
    var appIcon: String?
    var data: [GuideItem]?
}
