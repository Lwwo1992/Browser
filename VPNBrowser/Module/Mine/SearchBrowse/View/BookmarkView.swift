//
//  BookmarkView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/18.
//

import SwiftUI

struct BookmarkView: View {
    var bookmarks: [HistoryModel] = []
    
    @ObservedObject var viewModel = HistoryViewModel()
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.recordData) { model in
                        CollectionItemView(model: model)
                    }
                }
                .padding(.horizontal, 16)
            }
            OperateBottomView(viewModel: viewModel)
        }
        .environmentObject(viewModel)
    }
}

#Preview {
    BookmarkView()
}
