//
//  GuideView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/15.
//

import Kingfisher
import SwiftUI

struct GuideView: View {
    @State private var guideSections: [GuideResponse] = []

    let columns = Array(repeating: GridItem(.flexible()), count: S.Config.maxAppNum)
    let maxVisibleRows = 2 // 最多展示两排

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(guideSections, id: \.id) { senction in
                        if let rows = senction.data, !rows.isEmpty {
                            VStack(alignment: .leading) {
                                HStack {
//                                    KFImage(Util.getCompleteImageUrl(from: senction.appIcon))
//                                        .resizable()
//                                        .scaledToFill()
//                                        .frame(width: 20, height: 20)
//                                        .cornerRadius(5)
                                    Text(senction.name ?? "")
                                        .font(.headline)
                                        .padding(.leading, 16)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)

                                LazyVGrid(columns: columns, spacing: 20) {
                                    let displayedRows = min(rows.count, maxVisibleRows * columns.count)

                                    ForEach(0 ..< displayedRows, id: \.self) { index in
                                        if isMoreAppsButton(index: index, total: displayedRows, rows: rows) {
                                            moreAppsButton(data: senction)
                                        } else {
                                            appCell(for: rows[index])
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            loadGuideLabels()
        }
    }

    private func isMoreAppsButton(index: Int, total: Int, rows: [GuideItem]) -> Bool {
        return index == (columns.count * maxVisibleRows - 1) && total < rows.count
    }

    // 应用单元格视图
    @ViewBuilder
    private func appCell(for row: GuideItem) -> some View {
        VStack(spacing: 5) {
            KFImage(Util.getCompleteImageUrl(from: row.icon))
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .cornerRadius(5)

            Text(row.name ?? "")
                .font(.system(size: 14))
                .opacity(0.5)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .onTapGesture {
            Util.guideItemTap(row)
        }
    }

    // "更多应用" 按钮视图
    @ViewBuilder
    private func moreAppsButton(data: GuideResponse) -> some View {
        Button {
            let vc = MoreGuideViewController()
            vc.guideResponse = data
            Util.topViewController().navigationController?.pushViewController(vc, animated: true)
        } label: {
            VStack(spacing: 5) {
                Image(.more)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .cornerRadius(5)

                Text("更多应用")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .opacity(0.5)
            }
        }
    }
}

extension GuideView {
    private func loadGuideLabels() {
        HUD.showLoading()
        APIProvider.shared.request(.guideLabelPage, progress: { _ in }) { result in
            switch result {
            case let .success(response):
                if let responseLabels = GuideResponse.deserialize(from: String(data: response.data, encoding: .utf8)) {
                    if let labels = responseLabels.data {
                        fetchApps(for: labels)
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

#Preview {
    GuideView()
}
