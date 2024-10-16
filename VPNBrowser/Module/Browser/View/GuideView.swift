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
    let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: S.Config.maxAppNum)
    let maxVisibleRows = 2 // 最多展示两排

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(viewModel.guideSections, id: \.id) { senction in
                        if let rows = senction.data, !rows.isEmpty {
                            VStack(alignment: .leading) {
                                HStack {
                                    KFImage(Util.getCompleteImageUrl(from: senction.icon))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 20, height: 20)
                                        .cornerRadius(5)
                                    Text(senction.name ?? "")
                                        .font(.headline)
                                        .padding(.leading, 16)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)

                                LazyVGrid(columns: columns, spacing: itemSpacing) {
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
                .padding(.horizontal, 16)
            }
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

// #Preview {
//    GuideView()
// }
