//
//  TabView.swift
//  Browser
//
//  Created by xyxy on 2024/10/14.
//

import Kingfisher
import SDWebImageSwiftUI
import SwiftUI
import WebKit

struct TabsView: View {
    @ObservedObject var webViewStore: WebViewStore
    var bookmarkModel = HistoryModel()
    var onBookmarkAdded: ((HistoryModel) -> Void)?

    @State private var bookmarkes: [HistoryModel] = []
    @State private var showingDeleteAlert = false

    var body: some View {
        let width = (Util.deviceWidth - 52) * 0.5

        VStack {
            if !bookmarkes.isEmpty {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 20),
                        GridItem(.flexible(), spacing: 20),
                    ], spacing: 20) {
                        ForEach(bookmarkes, id: \.self) { model in
                            VStack(spacing: 10) {
                                ZStack(alignment: .topTrailing) {
                                    WebImage(url: model.url) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: width, height: width * 1.4)
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                            )
                                    } placeholder: {
                                        Rectangle()
                                            .fill(Color.white)
                                            .frame(width: width, height: width * 1.4)
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                            )
                                    }

                                    Button(action: {
                                        delete(model)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                            .padding(5)
                                    }
                                }
                                .onTapGesture {
                                    onBookmarkAdded?(model)
                                }

                                Text(model.title ?? "")
                                    .font(.system(size: 12))
                                    .foregroundColor(.black)
                            }
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

            HStack(spacing: 0) {
                Button {
                    if bookmarkes.count < 0 {
                        HUD.showTipMessage("无内容删除")
                        return
                    }
                    showingDeleteAlert = true
                } label: {
                    Text("删除")
                }
                .alert(isPresented: $showingDeleteAlert) {
                    Alert(
                        title: Text("删除标签"),
                        message: Text("您确定要删除所有标签吗？"),
                        primaryButton: .destructive(Text("删除")) {
                            deleteAllBookmarkes()
                        },
                        secondaryButton: .cancel()
                    )
                }

                Spacer()

                Button {
                    if let viewControllers = Util.topViewController().navigationController?.viewControllers {
                        if viewControllers.count > 1 {
                            let previousViewController = viewControllers[viewControllers.count - 2]
                            if previousViewController is BrowserWebViewController || S.Config.mode == .web {
                                if let viewController = viewControllers.first(where: { $0 is SearchViewController }) {
                                    webViewStore.addTab()
                                    Util.topViewController().navigationController?.popToViewController(viewController, animated: true)
                                }
                            } else {
                                DBaseManager.share.insertToDb(objects: [bookmarkModel], intoTable: S.Table.guideBookmark)
                                Util.topViewController().navigationController?.popViewController(animated: true)
                            }
                        }
                    }

                } label: {
                    Text("添加")
                }
            }
            .font(.system(size: 16))
            .foregroundColor(.black)
            .padding(.all, 10)
            .padding(.horizontal, 20)
        }
        .onAppear {
            fetchRecords()
        }
    }

    private func fetchRecords() {
        if let viewControllers = Util.topViewController().navigationController?.viewControllers {
            if viewControllers.count > 1 {
                let previousViewController = viewControllers[viewControllers.count - 2]
                if previousViewController is BrowserWebViewController || S.Config.mode == .web {
                    if let bookmarkes = DBaseManager.share.qureyFromDb(fromTable: S.Table.bookmark, cls: HistoryModel.self) {
                        self.bookmarkes = bookmarkes.reversed()
                    }
                } else {
                    if let bookmarkes = DBaseManager.share.qureyFromDb(fromTable: S.Table.guideBookmark, cls: HistoryModel.self) {
                        self.bookmarkes = bookmarkes.reversed()
                    }
                }
            }
        }
    }

    private func deleteAllBookmarkes() {
        bookmarkes.removeAll()
        if let viewControllers = Util.topViewController().navigationController?.viewControllers {
            if viewControllers.count > 1 {
                let previousViewController = viewControllers[viewControllers.count - 2]
                if previousViewController is BrowserWebViewController || S.Config.mode == .web {
                    DBaseManager.share.deleteFromDb(fromTable: S.Table.bookmark)
                } else {
                    DBaseManager.share.deleteFromDb(fromTable: S.Table.guideBookmark)
                }
            }
        }
    }

    private func delete(_ bookmark: HistoryModel) {
        // 从 bookmarkes 数组中删除对应的 bookmark
        bookmarkes.removeAll { $0.id == bookmark.id }

        if let viewControllers = Util.topViewController().navigationController?.viewControllers {
            if viewControllers.count > 1 {
                let previousViewController = viewControllers[viewControllers.count - 2]
                if previousViewController is BrowserWebViewController || S.Config.mode == .web {
                    DBaseManager.share.deleteFromDb(
                        fromTable: S.Table.bookmark,
                        where: HistoryModel.Properties.id == bookmark.id
                    )
                } else {
                    DBaseManager.share.deleteFromDb(
                        fromTable: S.Table.guideBookmark,
                        where: HistoryModel.Properties.id == bookmark.id
                    )
                }
            }
        }
    }
}
