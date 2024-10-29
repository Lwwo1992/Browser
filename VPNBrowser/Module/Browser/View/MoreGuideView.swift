//
//  MoreGuideView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/15.
//

import SDWebImageSwiftUI
import SwiftUI

struct MoreGuideView: View {
    var guideResponse = GuideResponse()

    // 每排间隔
    let itemSpacing: CGFloat = 30
    // 最多展示两排
    let maxVisibleRows = 2
    // 每排展示个数
    let maxAppNum = S.Config.maxAppNum

    // 动态列数
    var columns: [GridItem] {
        let totalWidth = UIScreen.main.bounds.width - 32 - CGFloat(maxAppNum) * 10
        let itemWidth = (totalWidth - CGFloat(maxAppNum - 1) * itemSpacing) / CGFloat(maxAppNum)
        return Array(repeating: GridItem(.flexible(minimum: itemWidth), spacing: itemSpacing), count: maxAppNum)
    }

    var body: some View {
        let totalWidth = UIScreen.main.bounds.width - 32
        let itemWidth = (totalWidth - CGFloat(maxAppNum - 1) * itemSpacing) / CGFloat(maxAppNum)

        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(guideResponse.data!, id: \.id) { row in
                    VStack(spacing: 5) {
                        WebImage(url: Util.getGuideImageUrl(from: row.icon)) { Image in
                            Image
                                .resizable()
                                .scaledToFill()
                                .frame(width: itemWidth, height: itemWidth)
                                .cornerRadius(5)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray)
                                .cornerRadius(5)
                                .frame(width: itemWidth, height: itemWidth)
                        }

                        Text(row.name ?? "")
                            .font(.system(size: 14))
                            .opacity(0.5)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    .padding(.vertical, 5)
                    .padding(.horizontal, 8)
                    .background(Color.white)
                    .cornerRadius(8)
                    .onTapGesture {
                        Util.guideItemTap(row)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    MoreGuideView()
}
