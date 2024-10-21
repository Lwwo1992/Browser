//
//  GuideView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/15.
//

import SDWebImageSwiftUI
import SwiftUI

struct GuideView: View {
    @ObservedObject var viewModel = GuideViewModel()

    // 每排间隔
    let itemSpacing: CGFloat = 16
    // 最多展示两排
    let maxVisibleRows = 2
    // 每排展示个数
    var maxAppNum: Int {
        return S.Config.maxAppNum
    }

    // 动态列数
    var columns: [GridItem] {
        let totalWidth = UIScreen.main.bounds.width - 32
        let itemWidth = (totalWidth - CGFloat(maxAppNum - 1) * itemSpacing) / CGFloat(maxAppNum)
        return Array(repeating: GridItem(.flexible(minimum: itemWidth), spacing: itemSpacing), count: maxAppNum)
    }

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(viewModel.guideSections, id: \.id) { section in
                        if let rows = section.data, !rows.isEmpty {
                            VStack(alignment: .leading) {
                                HStack {
//                                    WebImage(url: Util.getCompleteImageUrl(from: section.icon)) { image in
//                                        image
//                                            .resizable()
//                                            .scaledToFill()
//                                            .frame(width: 20, height: 20)
//                                            .cornerRadius(5)
//                                    } placeholder: {}
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
        let totalWidth = UIScreen.main.bounds.width - 32
        let itemWidth = (totalWidth - CGFloat(maxAppNum - 1) * itemSpacing) / CGFloat(maxAppNum)

        VStack(spacing: 5) {
            WebImage(url: Util.getCompleteImageUrl(from: row.icon)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: itemWidth * 0.4, height: itemWidth * 0.4)
                    .cornerRadius(5)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .cornerRadius(2)
                    .frame(width: itemWidth * 0.4, height: itemWidth * 0.4)
            }

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
        let itemWidth = (totalWidth - CGFloat(maxAppNum - 1) * itemSpacing) / CGFloat(maxAppNum)

        Button {
            let vc = MoreGuideViewController()
            vc.guideResponse = data
            Util.topViewController().navigationController?.pushViewController(vc, animated: true)
        } label: {
            VStack(spacing: 5) {
                Image(.more)
                    .resizable()
                    .scaledToFit()
                    .frame(width: itemWidth * 0.4, height: itemWidth * 0.4)
                    .cornerRadius(5)

                Text("更多应用")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .opacity(0.5)
            }
        }
    }
}
