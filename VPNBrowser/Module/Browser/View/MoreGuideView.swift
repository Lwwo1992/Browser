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

    let imageWidth: CGFloat = 40

    var maxAppNum: Int {
        return S.Config.maxAppNum
    }

    var columns: [GridItem] {
        return Array(repeating: GridItem(.flexible(minimum: 50), spacing: 10), count: 5)
    }

    var body: some View {

        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(guideResponse.data!, id: \.id) { row in
                    VStack(spacing: 5) {
                        WebImage(url: Util.getGuideImageUrl(from: row.icon)) { Image in
                            Image
                                .resizable()
                                .scaledToFill()
                                .frame(width: imageWidth, height: imageWidth)
                                .cornerRadius(5)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray)
                                .cornerRadius(5)
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
            }
            .padding(.horizontal, 16)
        }
    }
}
