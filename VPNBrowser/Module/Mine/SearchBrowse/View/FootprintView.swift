//
//  FootprintView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/9.
//

import SwiftUI

struct FootprintView: View {
    @ObservedObject var viewModel: FootprintViewModel

    @State private var content: String = ""

    var body: some View {
        VStack(spacing: 20) {
//            TextField("搜索内容", text: $content)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .font(.system(size: 14))

            if viewModel.selectedSegmentIndex == 0 {
                BrowseHistory()
            } else {
                BrowseHistory()
            }
        }
        .padding(.top, 8)
    }
}

#Preview {
    FootprintView(viewModel: FootprintViewModel())
}