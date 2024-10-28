//
//  TabView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/14.
//

import Kingfisher
import SDWebImageSwiftUI
import SwiftUI
import WebKit

struct TabsView: View {
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
                    let newBookmark = bookmarkModel.copy() as! HistoryModel
                    DBaseManager.share.insertToDb(objects: [newBookmark], intoTable: S.Table.bookmark)
                    bookmarkes.insert(newBookmark, at: 0)
                    Util.topViewController().navigationController?.popToRootViewController(animated: true)
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
        if let bookmarkes = DBaseManager.share.qureyFromDb(fromTable: S.Table.bookmark, cls: HistoryModel.self) {
            self.bookmarkes = bookmarkes.reversed()
        }
    }

    private func deleteAllBookmarkes() {
        bookmarkes.removeAll()
        DBaseManager.share.deleteFromDb(fromTable: S.Table.bookmark)
    }

    private func delete(_ bookmark: HistoryModel) {
        // 从 bookmarkes 数组中删除对应的 bookmark
        bookmarkes.removeAll { $0.id == bookmark.id }

        // 从数据库中删除对应的记录
        DBaseManager.share.deleteFromDb(
            fromTable: S.Table.bookmark,
            where: HistoryModel.Properties.id == bookmark.id
        )
    }
}

#Preview {
    TabsView()
}
