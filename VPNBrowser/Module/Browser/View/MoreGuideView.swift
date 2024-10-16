//
//  MoreGuideView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/15.
//

import Kingfisher
import SwiftUI

struct MoreGuideView: View {
    var guideResponse = GuideResponse()

    let columns = Array(repeating: GridItem(.flexible()), count: S.Config.maxAppNum)

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(guideResponse.data!, id: \.id) { row in
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
            }
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    MoreGuideView()
}
