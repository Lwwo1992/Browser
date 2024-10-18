//
//  CollectionRecordView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/18.
//

import SwiftUI

struct CollectionView: View {
    @EnvironmentObject var viewModel: HistoryViewModel

    var body: some View {
        Group {
            if !viewModel.recordData.isEmpty || !viewModel.folderData.isEmpty {
                VStack {
                    ScrollView {
                        LazyVStack {
                            ForEach(viewModel.folderData) { model in
                                FolderItemView(model: model)
                            }

                            ForEach(viewModel.recordData) { model in
                                CollectionItemView(model: model)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    OperateBottomView(viewModel: viewModel)
                }
            } else {
                Text("暂无数据")
                    .font(.system(size: 16))
            }
        }
        .environmentObject(viewModel)
    }
}

struct FolderItemView: View {
    @ObservedObject var model: FolderModel
    @EnvironmentObject var viewModel: HistoryViewModel

    var body: some View {
        VStack {
            HStack {
                if viewModel.isEdit {
                    Image(systemName: !model.isSelected ? "circle" : "checkmark.circle")
                        .font(.system(size: 14, weight: .medium))
                        .opacity(0.6)
                        .onTapGesture {
                            model.isSelected.toggle()
                            viewModel.updateSelectedFolderArray(for: model)
                            print("Folder \(model.name) isSelected: \(model.isSelected)")
                        }
                }

                Image(systemName: "folder")
                    .font(.system(size: 20))

                VStack(alignment: .leading, spacing: 5) {
                    Text(model.name)
                        .font(.system(size: 14))
                    Text("\(model.bookmarks.count)个书签")
                        .font(.system(size: 12))
                        .opacity(0.5)
                }

                Spacer()

                Image(systemName: "chevron.right")
            }
            .frame(maxHeight: .infinity, alignment: .center)
            .background(Color(hex: 0xF8F5F5))
            .onTapGesture {
                let vc = BookmarkViewController()
                vc.title = model.name
                vc.bookmarks = model.bookmarks
                Util.topViewController().navigationController?.pushViewController(vc, animated: true)
            }

            Divider()
        }
        .frame(height: 50)
    }
}

struct CollectionItemView: View {
    @ObservedObject var model: HistoryModel
    @EnvironmentObject var viewModel: HistoryViewModel

    var body: some View {
        VStack {
            HStack(spacing: 10) {
                if viewModel.isEdit {
                    Image(systemName: !model.isSelected ? "circle" : "checkmark.circle")
                        .onTapGesture {
                            model.isSelected.toggle()
                            viewModel.updateSelectedArray(for: model)
                            print("History \(model.path ?? "") isSelected: \(model.isSelected)")
                        }
                }

                Image(systemName: "network")
                    .font(.system(size: 16))
                Text(model.path ?? "")
                    .font(.system(size: 12))
                    .opacity(0.5)

                Spacer()

                Text(Util.formattedTime(from: model.timestamp))
                    .font(.system(size: 12))
                    .opacity(0.5)
            }
            .font(.system(size: 14, weight: .medium))
            .opacity(0.6)
            .frame(height: 30)

            Divider()
        }
    }
}
