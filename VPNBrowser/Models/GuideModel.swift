//
//  GuideModel.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/15.
//

import UIKit

class GuideViewModel: ObservableObject {
    @Published var guideSections: [GuideResponse] = []

    init() {
        loadGuideLabels()
    }

    private func loadGuideLabels() {
        HUD.showLoading()
        APIProvider.shared.request(.guideLabelPage, progress: { _ in }) { [weak self] result in
            HUD.hideNow()
            guard let self else { return }
            switch result {
            case let .success(response):
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
        var sections: [GuideResponse] = []

        for label in labels {
            guard let id = label.id else { continue }
            group.enter()

            APIProvider.shared.request(.guideAppPage(labelID: id), progress: { _ in }) { result in
                switch result {
                case let .success(response):
                    if let responseApps = GuideResponse.deserialize(from: String(data: response.data, encoding: .utf8)) {
                        let apps = responseApps.data ?? []

                        let section = GuideResponse()
                        section.name = label.name
                        section.data = apps
                        sections.append(section)

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
