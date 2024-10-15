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

    @State private var guideItems: [GuideItem] = []
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
                List {
                    ForEach(guideItems, id: \.id) { item in
                        Section(header: Text(item.name ?? "Unknown")) {
                            // Placeholder for apps or additional content for each guide item
                            Text("Apps for \(item.name ?? "Unknown")") // 这里可以放置应用的列表
                        }
                    }
                }
            }
        }
        .onAppear {
            loadGuideLabels()
//            APIProvider.shared.request(.guideLabelPage, progress: { _ in
//
//            }) { result in
//                switch result {
//                case let .success(response):
//                    if let responseString = String(data: response.data, encoding: .utf8) {
//                        print("Response: \(responseString)") // 打印响应内容，方便调试
//                    }
//                    if let responseLabels = GuideResponse.deserialize(from: String(data: response.data, encoding: .utf8)) {
//                        if let list = responseLabels.data {
//                            list.forEach { item in
//                                if let id = item.id {
//                                    APIProvider.shared.request(.guideAppPage(labelID: id), progress: { _ in
//
//                                    }) { result in
//                                        switch result {
//                                        case let .success(response):
//                                            if let responseString = String(data: response.data, encoding: .utf8) {
//                                                print("Response: \(responseString)")
//                                            }
//                                            if let responseApps = GuideResponse.deserialize(from: String(data: response.data, encoding: .utf8)) {
//                                                let apps = responseApps.data
//                                            } else {
//                                                print("Error decoding JSON with HandyJSON.")
//                                            }
//
//                                        case let .failure(error):
//                                            print("Error: \(error)")
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    } else {
//                        print("Error decoding JSON with HandyJSON.")
//                    }
//
//                case let .failure(error):
//                    print("Error: \(error)")
//                }
//            }
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

        for label in labels {
            guard let id = label.id else { continue }
            group.enter()

            APIProvider.shared.request(.guideAppPage(labelID: id), progress: { _ in }) { result in
                switch result {
                case let .success(response):
                    if let responseApps = GuideResponse.deserialize(from: String(data: response.data, encoding: .utf8)) {
                        // Append apps to guideItems or do additional processing if necessary
                        guideItems.append(contentsOf: responseApps.data ?? [])
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
            isLoading = false // Set loading to false when all requests are done
        }
    }
}

#Preview {
    BrowserView()
}
