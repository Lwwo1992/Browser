//
//  BookmarkView.swift
//  Browser
//
//  Created by xyxy on 2024/10/18.
//

import SwiftUI

struct BookmarkView: View {
    var id: String = ""

    @ObservedObject var viewModel = HistoryViewModel()

    var body: some View {
        Group {
            if !viewModel.recordData.isEmpty {
                VStack {
                    ScrollView {
                        LazyVStack {
                            ForEach(viewModel.recordData) { model in
                                CollectionItemView(model: model)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    OperateBottomView(showFolder: false)
                }
            } else {
                Spacer()
                Text("暂无数据")
                    .font(.system(size: 16))
                Spacer()
            }
        }
        .environmentObject(viewModel)
        .onAppear {
            viewModel.recordData = DBaseManager.share.qureyFromDb(
                fromTable: S.Table.collect,
                cls: HistoryModel.self,
                where: HistoryModel.Properties.parentId == id
            )?.reversed() ?? []
        }
    }
}

#Preview {
    BookmarkView()
}
