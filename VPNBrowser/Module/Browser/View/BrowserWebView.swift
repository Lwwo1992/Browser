//
//  WebView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/14.
//

import JFPopup
import SwiftUI

struct BrowserWebView: View {
    @State private var isCollect = false
    @State private var bookmarNum = "0"
    @ObservedObject var viewModel: WebViewViewModel

    var body: some View {
        VStack {
            searchBar()

            WebViewWrapper(viewModel: viewModel)

            bottomView()
        }
        .onAppear {
            if let array = DBaseManager.share.qureyFromDb(fromTable: S.Table.collect, cls: HistoryModel.self, where: HistoryModel.Properties.address == viewModel.urlString), !array.isEmpty {
                isCollect = true
            }
        }
        .onAppear {
            if let bookmarkes = DBaseManager.share.qureyFromDb(fromTable: S.Table.bookmark, cls: HistoryModel.self) {
                self.bookmarNum = "\(bookmarkes.count)"
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
                .lineLimit(1)
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
        .frame(height: 35)
        .padding(.horizontal, 10)
        .cornerRadius(17)
        .overlay(
            RoundedRectangle(cornerRadius: 17)
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func bottomView() -> some View {
        HStack {
            Image(systemName: "chevron.left")
                .font(.system(size: 20))
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    viewModel.action = .goBack
                }

            Image(systemName: "arrow.clockwise")
                .font(.system(size: 20))
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    withAnimation {
                        withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                            viewModel.refresh = true
                        }
                    }
                }

            RoundedRectangle(cornerRadius: 2)
                .fill(Color.clear)
                .frame(width: 18, height: 18)
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color.black, lineWidth: 1.5)
                )
                .overlay(
                    Text(bookmarNum)
                        .font(.system(size: 12, weight: .medium))
                )
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    let vc = TabsViewController()
                    vc.model = viewModel.bookmark
                    vc.onBookmarkAdded = { bookmark in
                        if let address = bookmark.address {
                            viewModel.shouldUpdate = true
                            viewModel.urlString = address
                        }
                    }
                    Util.topViewController().navigationController?.pushViewController(vc, animated: true)
                }

            Image(systemName: "ellipsis")
                .font(.system(size: 20))
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    viewModel.showBottomSheet.toggle()
                }

            Image(systemName: "house")
                .font(.system(size: 20))
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    Util.topViewController().navigationController?.popToRootViewController(animated: false)
                }
        }
        .font(.system(size: 14))
        .frame(height: 50)
        .background(Color.gray.opacity(0.1))
    }
}

extension BrowserWebView {
    private func handleCollectAction() {
        if let array = DBaseManager.share.qureyFromDb(fromTable: S.Table.folder, cls: FolderModel.self), !array.isEmpty {
            presentFolderDialog(with: array)
        } else {
            updateDatabase()
        }
    }

    // 弹出文件夹选择对话框
    private func presentFolderDialog(with folders: [FolderModel]) {
        if !isCollect {
            Util.topViewController().popup.dialog {
                let folderDialog = FolderDialogView(frame: CGRect(x: 0, y: 0, width: 240, height: 260))
                folderDialog.array = folders
                folderDialog.onFolderSelected = { folder in
                    guard let folder else {
                        return
                    }

                    updateDatabase(for: folder)
                }
                return folderDialog
            }
        } else {
            updateDatabase()
        }
    }

    // 更新数据库状态
    private func updateDatabase(for folder: FolderModel = FolderModel()) {
        isCollect.toggle()

        let model = HistoryModel()
        model.parentId = folder.id
        model.name = viewModel.bookmark.title ?? "未知"
        model.address = viewModel.urlString

        if isCollect {
            DBaseManager.share.insertToDb(objects: [model], intoTable: S.Table.collect)
        } else {
            DBaseManager.share.deleteFromDb(fromTable: S.Table.collect, where: HistoryModel.Properties.address == viewModel.urlString)
        }
    }
}
