//
//  MineView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/8.
//

import SwiftUI

struct MineView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            MineTopView()
                .padding(.top, Util.safeAreaInsets.top)
            MineBottomView()
        }
        .padding(.horizontal, 16)
        .background(Color(hex: 0xF8F5F5))
    }
}

#Preview {
    MineView()
}
