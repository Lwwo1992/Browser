//
//  GuideView.swift
//  Browser
//
//  Created by xyxy on 2024/10/15.
//

import SDWebImageSwiftUI
import SwiftUI

struct GuideView: View {
    @ObservedObject var viewModel = GuideViewModel()

    let imageWidth: CGFloat = 40

    var maxAppNum: Int {
        return S.Config.maxAppNum
    }

    var columns: [GridItem] {
        return Array(repeating: GridItem(.flexible(minimum: 50), spacing: 10), count: 5)
    }

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(viewModel.guideSections, id: \.id) { section in
                        if let rows = section.data, !rows.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(spacing: 5) {
                                    WebImage(url: Util.getGuideImageUrl(from: section.appIcon)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 20, height: 20)
                                            .cornerRadius(5)
                                    } placeholder: {}
                                    Text(section.name ?? "")
                                        .font(.system(size: 14))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)

                                LazyVGrid(columns: columns, spacing: 10) {
                                    let displayedRows = min(rows.count, maxAppNum)
                                    if displayedRows < 3 {
                                        ForEach(0 ..< displayedRows, id: \.self) { index in
                                            appCell(for: rows[index])
                                        }
                                    } else {
                                        ForEach(0 ..< displayedRows - 1, id: \.self) { index in
                                            appCell(for: rows[index])
                                        }
                                        if displayedRows == maxAppNum {
                                            moreAppsButton(data: section)
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
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func appCell(for row: GuideItem) -> some View {
        VStack(spacing: 5) {
            WebImage(url: Util.getGuideImageUrl(from: row.icon)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: imageWidth, height: imageWidth)
                    .cornerRadius(5)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .cornerRadius(2)
                    .frame(width: imageWidth, height: imageWidth)
            }

            Text(row.name ?? "")
                .font(.system(size: 12))
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
        Button {
            let vc = MoreGuideViewController()
            vc.guideResponse = data
            Util.topViewController().navigationController?.pushViewController(vc, animated: true)
        } label: {
            VStack(spacing: 5) {
                Image(systemName: "square.grid.2x2")
                    .font(.system(size: imageWidth - 10))
                    .foregroundColor(.black)

                Text("更多应用")
                    .font(.system(size: 14))
                    .lineLimit(1)
                    .foregroundColor(.black)
                    .opacity(0.5)
            }
            .cornerRadius(8)
        }
    }
}
