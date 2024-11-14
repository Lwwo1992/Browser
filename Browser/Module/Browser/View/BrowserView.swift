//
//  BrowserView.swift
//  Browser
//
//  Created by xyxy on 2024/10/10.
//

import Kingfisher
import SwiftUI

struct BrowserView: View {
    @ObservedObject var webViewModel: WebViewViewModel
    @ObservedObject var webViewStore: WebViewStore
    @State private var bookmarNum = "0"

    var body: some View {
        VStack {
            HStack {
                searchBar
                notificationBadge
            }
            .padding(.horizontal, 16)

            if ViewModel.shared.selectedModel == .web {
                webView()
            } else {
                GuideView()
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }

    @ViewBuilder
    private func webView() -> some View {
        WebView(webView: webViewStore.webView)
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")

            Text("全网搜索")
                .font(.system(size: 14))
                .opacity(0.5)

            Spacer()

            Image(systemName: "viewfinder")
                .onTapGesture {
                    webViewModel.scanCode = true
                }
        }
        .padding(.horizontal, 10)
        .frame(height: 35)
        .background(
            Color.white
                .cornerRadius(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray, lineWidth: 1)
                )
        )
        .onTapGesture {
            Util.topViewController().navigationController?.pushViewController(SearchViewController(), animated: true)
        }
    }

    private var notificationBadge: some View {
        Rectangle()
            .fill(Color.white)
            .frame(width: 25, height: 25)
            .cornerRadius(2)
            .overlay(
                Text(bookmarNum)
                    .font(.system(size: 12))
                    .foregroundColor(.black)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .onTapGesture {
                let vc = TabsViewController()
                vc.model = S.Config.mode == .web ? webViewModel.bookmark : webViewModel.guideBookmark
                vc.onBookmarkAdded = { model in
                    webViewModel.shouldUpdate = true
                    webViewModel.urlString = model.address ?? ""
                }
                Util.topViewController().navigationController?.pushViewController(vc, animated: true)
            }
            .onAppear {
                if let bookmarkes = DBaseManager.share.qureyFromDb(fromTable: S.Config.mode == .web ? S.Table.bookmark : S.Table.guideBookmark, cls: HistoryModel.self) {
                    self.bookmarNum = "\(bookmarkes.count)"
                }
            }
    }
}
