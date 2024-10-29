//
//  FootprintView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/9.
//

import SwiftUI

struct FootprintView: View {
    @ObservedObject var viewModel: HistoryViewModel

    var body: some View {
        VStack(spacing: 20) {
            if viewModel.selectedSegmentIndex == 0 {
                CollectionView()
            } else {
                HistoryView()
            }
        }
        .padding(.top, 8)
        .environmentObject(viewModel)
        .onAppear {
            viewModel.loadFolderData()
        }
        .onChange(of: viewModel.selectedSegmentIndex) { _ in
            viewModel.loadFolderData()
        }
    }
}
