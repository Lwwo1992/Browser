//
//  BrowserView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/10.
//

import Kingfisher
import SwiftUI

struct BrowserView: View {
    @StateObject var webViewModel = WebViewViewModel()
    @StateObject private var viewModel = ViewModel.shared
    @State private var bookmarNum = "0"

    var body: some View {
        VStack {
            HStack {
                searchBar
                notificationBadge
            }
            .padding(.horizontal, 16)

            if viewModel.selectedModel == .web {
                webView()
            } else {
                GuideView()
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .onAppear {
            webViewModel.shouldUpdate = viewModel.updateWeb
            webViewModel.urlString = S.Config.defalutUrl
        }
    }

    @ViewBuilder
    private func webView() -> some View {
        WebViewWrapper(viewModel: webViewModel)
            .frame(maxHeight: .infinity)
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")

            Text("全网搜索")
                .font(.system(size: 14))
                .opacity(0.5)

            Spacer()
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
                vc.model = webViewModel.guideBookmark
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
