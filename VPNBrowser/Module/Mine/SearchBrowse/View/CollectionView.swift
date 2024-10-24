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
        VStack {
            if !viewModel.recordData.isEmpty || !viewModel.folderData.isEmpty {
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
            } else {
                Spacer()
                Text("暂无数据")
                    .font(.system(size: 16))
                Spacer()
            }
            OperateBottomView(viewModel: viewModel)
        }.environmentObject(viewModel)
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
                    Text("\(model.children.count)个书签")
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
                vc.folderID = model.id
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
                            print("History \(model.address ?? "") isSelected: \(model.isSelected)")
                        }
                }

                Image(systemName: "network")
                    .font(.system(size: 16))
                Text(model.address ?? "")
                    .font(.system(size: 12))
                    .opacity(0.5)
            }
            .font(.system(size: 14, weight: .medium))
            .opacity(0.6)
            .frame(height: 30)
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()
        }
        .background(Color(hex: 0xF8F5F5))
        .onTapGesture {
            let vc = BrowserWebViewController()
            vc.path = model.address ?? ""
            Util.topViewController().navigationController?.pushViewController(vc, animated: true)
        }
    }
}
