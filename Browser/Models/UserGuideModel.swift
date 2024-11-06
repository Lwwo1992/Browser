//
//  UserGuideModel.swift
//  Browser
//
//  Created by xyxy on 2024/10/16.
//

import UIKit

class UserGuideViewModel: ObservableObject {
    @Published var userGuideData: [UserGuideResponse] = []

    init() {
        loadData()
    }

    func loadData() {
        HUD.showLoading()
        APIProvider.shared.request(.userGuidePage, model: UserGuideResponse.self) { result in
            HUD.hideNow()
            switch result {
            case let .success(model):
                if let record = model.record {
                    let groupedData = Dictionary(grouping: record) { $0.classifyName ?? "未知" }
                    let classifiedData = groupedData.map { key, value in
                        UserGuideResponse(title: key, record: value)
                    }
                    DispatchQueue.main.async {
                        self.userGuideData = classifiedData
                    }
                }
            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }
}

class UserGuideResponse: BaseModel {
    var title: String?
    var record: [UserGuideModel]?

    convenience init(title: String? = nil, record: [UserGuideModel]? = nil) {
        self.init()
        self.title = title
        self.record = record
    }
}

class UserGuideModel: BaseModel {
    var icon: String?
    var title: String?
    var content: String?
    var subtitle: String?
    var classifyName: String?
}
