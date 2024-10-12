//
//  HomeView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/12.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            VerifyCodeView { _ in
            }
            .frame(width: 320)
            .frame(height: 45)
        }
    }
}

#Preview {
    HomeView()
}
