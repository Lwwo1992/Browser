//
//  GuideView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/15.
//

import Kingfisher
import SwiftUI

struct GuideView: View {
    @ObservedObject var viewModel = GuideViewModel()

    let itemSpacing: CGFloat = 16
    let maxVisibleRows = 2 // 最多展示两排

    // 动态列数
    var columns: [GridItem] {
        let totalWidth = UIScreen.main.bounds.width - 32 // 减去两侧的 padding
        let itemWidth = (totalWidth - CGFloat(S.Config.maxAppNum - 1) * itemSpacing) / CGFloat(S.Config.maxAppNum)
        return Array(repeating: GridItem(.flexible(minimum: itemWidth), spacing: itemSpacing), count: S.Config.maxAppNum)
    }

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(viewModel.guideSections, id: \.id) { section in
                        if let rows = section.data, !rows.isEmpty {
                            VStack(alignment: .leading) {
                                HStack {
                                    KFImage(Util.getCompleteImageUrl(from: section.icon))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 20, height: 20)
                                        .cornerRadius(5)
                                    Text(section.name ?? "")
                                        .font(.headline)
                                        .padding(.leading, 16)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)

                                LazyVGrid(columns: columns, spacing: itemSpacing) {
                                    let displayedRows = min(rows.count, maxVisibleRows * columns.count)

                                    ForEach(0 ..< displayedRows, id: \.self) { index in
                                        if isMoreAppsButton(index: index, total: displayedRows, rows: rows) {
                                            moreAppsButton(data: section)
                                        } else {
                                            appCell(for: rows[index])
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func isMoreAppsButton(index: Int, total: Int, rows: [GuideItem]) -> Bool {
        return index == (columns.count * maxVisibleRows - 1) && total < rows.count
    }

    @ViewBuilder
    private func appCell(for row: GuideItem) -> some View {
        let totalWidth = UIScreen.main.bounds.width - 32 // 减去两侧的 padding
        let itemWidth = (totalWidth - CGFloat(S.Config.maxAppNum - 1) * itemSpacing) / CGFloat(S.Config.maxAppNum)

        VStack(spacing: 5) {
            KFImage(Util.getCompleteImageUrl(from: row.icon))
                .resizable()
                .scaledToFill()
                .frame(width: itemWidth * 0.4, height: itemWidth * 0.4) // 图标宽高为 item 宽度的 40%
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

    @ViewBuilder
    private func moreAppsButton(data: GuideResponse) -> some View {
        let totalWidth = UIScreen.main.bounds.width - 32
        let itemWidth = (totalWidth - CGFloat(S.Config.maxAppNum - 1) * itemSpacing) / CGFloat(S.Config.maxAppNum)

        Button {
            let vc = MoreGuideViewController()
            vc.guideResponse = data
            Util.topViewController().navigationController?.pushViewController(vc, animated: true)
        } label: {
            VStack(spacing: 5) {
                Image(.more)
                    .resizable()
                    .scaledToFit()
                    .frame(width: itemWidth * 0.4, height: itemWidth * 0.4) // 图标宽高为 item 宽度的 40%
                    .cornerRadius(5)

                Text("更多应用")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .opacity(0.5)
            }
        }
    }
}
