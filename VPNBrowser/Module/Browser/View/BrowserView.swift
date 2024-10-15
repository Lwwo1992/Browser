//
//  BrowserView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/10.
//

import SwiftUI

struct BrowserView: View {
    @StateObject private var webViewModel = WebViewViewModel()
    @State private var bookmarkModel = HistoryModel()
    @State private var bookmarNum = "0"

    @State private var guideSections: [GuideResponse] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack {
            HStack {
                searchBar
                notificationBadge
            }
            .padding(.horizontal, 16)

            contentView()
        }
    }

    @ViewBuilder
    private func contentView() -> some View {
        if S.Config.mode == .web {
            webView()
        } else {
            GuideView()
        }
    }

    @ViewBuilder
    private func webView() -> some View {
        WebView(urlString: S.Config.defalutUrl, viewModel: webViewModel, onSaveInfo: { model in
            self.bookmarkModel = model
        })
        .frame(maxHeight: .infinity)
    }

    @ViewBuilder
    private func GuideView() -> some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
            } else {
//                ScrollView {
//                    VStack(alignment: .leading, spacing: 20) {
//                        ForEach(guideSections, id: \.id) { guideItem in
//                            VStack(alignment: .leading) {
//                                
//                                Text(guideItem.groupTitle)
//                                    .font(.headline)
//                                    .padding(.leading, 16)
//
//                                // 应用的水平滚动视图
//                                ScrollView(.horizontal, showsIndicators: false) {
//                                    HStack(spacing: 10) {
//                                        ForEach(guideItem.apps ?? [], id: \.id) { app in
//                                            AppView(appName: app.name)
//                                        }
//                                    }
//                                    .padding(.horizontal, 16)
//                                }
//                            }
//                        }
//                    }
//                }
            }
        }
        .onAppear {
            loadGuideLabels()
        }
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
                let vc = TabViewController()
                vc.model = bookmarkModel
                Util.topViewController().navigationController?.pushViewController(vc, animated: true)
            }
            .onAppear {
                if let bookmarkes = DBaseManager.share.qureyFromDb(fromTable: S.Table.bookmark, cls: HistoryModel.self) {
                    self.bookmarNum = "\(bookmarkes.count)"
                }
            }
    }
}

extension BrowserView {
    private func loadGuideLabels() {
        APIProvider.shared.request(.guideLabelPage, progress: { _ in }) { result in
            switch result {
            case let .success(response):
                if let responseLabels = GuideResponse.deserialize(from: String(data: response.data, encoding: .utf8)) {
                    if let labels = responseLabels.data {
                        fetchApps(for: labels)
                    } else {
                        errorMessage = "No labels found."
                        isLoading = false
                    }
                } else {
                    errorMessage = "Error decoding labels."
                    isLoading = false
                }

            case let .failure(error):
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }

    private func fetchApps(for labels: [GuideItem]) {
        let group = DispatchGroup()
        var sections: [GuideResponse] = []

        for label in labels {
            guard let id = label.id else { continue }
            group.enter()

            APIProvider.shared.request(.guideAppPage(labelID: id), progress: { _ in }) { result in
                switch result {
                case let .success(response):
                    if let responseApps = GuideResponse.deserialize(from: String(data: response.data, encoding: .utf8)) {
                        let apps = responseApps.data ?? []

                        let section = GuideResponse()
                        section.name = label.name
                        section.data = apps
                        sections.append(section)

                    } else {
                        print("Error decoding apps.")
                    }

                case let .failure(error):
                    print("Error: \(error)")
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.guideSections = sections
            isLoading = false
        }
    }
}

#Preview {
    BrowserView()
}
