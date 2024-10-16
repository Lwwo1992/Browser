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
            Text("福利参与")
                .font(.system(size: 16))
                .foregroundColor(.white)
            Text("已有1281人参与")
                .font(.system(size: 12))
                .opacity(0.5)

            VStack(spacing: 5) {
                Text("30天")
                    .font(.system(size: 30))
                    .foregroundColor(.white)

                Text("畅想VPN")
                    .font(.system(size: 14))
                    .foregroundColor(.white)

                Text("在邀请5人,直接免费拿")
                    .font(.system(size: 12))
            }
            .padding(.top, 20)

            HStack(spacing: 10) {
                ForEach(0 ..< 5) { _ in
                    Image("convite")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }
            }
            .frame(width: 210)
            .frame(height: 50)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(20)
            .padding(.horizontal, 16)
            .padding(.top, 30)

            Spacer()
        }
    }
}

// #Preview {
//    HomeView()
// }
