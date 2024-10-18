//
//  WebView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/14.
//

import JFPopup
import SwiftUI

struct BrowserWebView: View {
    @State private var isSheetPresented = false
    @State private var isCollect = false
    @ObservedObject var viewModel: WebViewViewModel

    var body: some View {
        VStack {
            searchBar()

            WebView(viewModel: viewModel) { model in
                if !S.Config.openNoTrace {
                    DBaseManager.share.insertToDb(objects: [model], intoTable: S.Table.browseHistory)
                }
            }

            bottomView()
        }
        .onAppear {
            if let array = DBaseManager.share.qureyFromDb(fromTable: S.Table.collect, cls: HistoryModel.self, where: HistoryModel.Properties.path == viewModel.urlString), !array.isEmpty {
                isCollect = true
            }
        }
    }

    @ViewBuilder
    private func searchBar() -> some View {
        HStack {
            Image(systemName: "lock.shield")
                .font(.system(size: 20))

            Text(verbatim: viewModel.urlString)
                .font(.system(size: 14))
                .foregroundColor(.black)
                .opacity(0.5)
                .onTapGesture {
                    Util.topViewController().navigationController?.popViewController(animated: true)
                }

            Spacer()

            Image(systemName: isCollect ? "star.fill" : "star")
                .font(.system(size: 14))
                .foregroundColor(isCollect ? .yellow : .gray)
                .onTapGesture {
                    handleCollectAction()
                }
        }
        .frame(height: 40)
        .padding(.horizontal, 10)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func bottomView() -> some View {
        HStack {
            Text("返回")
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    Util.topViewController().navigationController?.popViewController(animated: true)
                }

            Spacer()

            Text("刷新")
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    viewModel.refresh = true
                }

            Spacer()

            Text("更多")
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    viewModel.showBottomSheet.toggle()
                }
        }
        .font(.system(size: 14))
        .padding(.vertical, 10)
        .background(Color.gray.opacity(0.1))
    }
}

extension BrowserWebView {
    private func handleCollectAction() {
        if let array = DBaseManager.share.qureyFromDb(fromTable: S.Table.folder, cls: FolderModel.self) {
            presentFolderDialog(with: array)
        } else {
            isCollect.toggle()
            updateDatabase()
        }
    }

    // 弹出文件夹选择对话框
    private func presentFolderDialog(with folders: [FolderModel]) {
        Util.topViewController().popup.dialog {
            let folderDialog = FolderDialogView(frame: CGRect(x: 0, y: 0, width: 240, height: 260))
            folderDialog.array = folders
            folderDialog.onFolderSelected = { folder in
                isCollect.toggle() // 切换收藏状态
                updateDatabase(for: folder) // 更新数据库
            }
            return folderDialog
        }
    }

    // 更新数据库状态
    private func updateDatabase(for folder: FolderModel? = nil) {
        let model = HistoryModel()
        model.path = viewModel.urlString
        if let folder {
            model.folderID = folder.id
        }

        if isCollect {
            DBaseManager.share.insertToDb(objects: [model], intoTable: S.Table.collect)
        } else {
            DBaseManager.share.deleteFromDb(fromTable: S.Table.collect, where: HistoryModel.Properties.path == viewModel.urlString)
        }
    }
}
