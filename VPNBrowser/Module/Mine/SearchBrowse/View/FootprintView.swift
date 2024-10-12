//
//  FootprintView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/9.
//

import SwiftUI

struct FootprintView: View {
    @State private var content: String = ""
    var body: some View {
        VStack(spacing: 20) {
            TextField("搜索内容", text: $content)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.system(size: 14))

            HStack(spacing: 10) {
                Image(systemName: "network")
                VStack(alignment: .leading, spacing: 5) {
                    Text("第12回 孙悟空三打白骨精_西游记白话文")
                        .font(.system(size: 14))
                    Text("m.gushufang.com")
                        .font(.system(size: 12))
                        .opacity(0.5)
                }
                Spacer()
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

#Preview {
    FootprintView()
}
