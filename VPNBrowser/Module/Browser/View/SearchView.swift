//
//  SearchView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/10.
//
import Kingfisher
import SDWebImageSwiftUI
import SwiftUI

struct SearchView: View {
    @ObservedObject var recordStore: RecordStore
    /// 热搜数据
    @State private var recors: [RankingModel]? = nil
    /// 搜索历史数据
    @State private var historise: [HistoryModel]? = nil

    @State private var showingDeleteAlert = false

    var body: some View {
        ScrollView {
            VStack {
                topView()
                historyView()
                RankingPageView()
            }
            .padding(.horizontal, 16)
        }
        .onAppear {
            APIProvider.shared.request(.rankingPage, model: RecordRankingModel.self) { result in
                switch result {
                case let .success(model):
                    recors = model.record
                case let .failure(error):
                    print("Request failed with error: \(error)")
                }
            }
        }
        .onAppear {
            historise = DBaseManager.share.qureyFromDb(fromTable: S.Table.searchHistory, cls: HistoryModel.self)?.reversed()
        }
    }

    @ViewBuilder
    private func topView() -> some View {
        FlowLayout(items: recordStore.records) { record in
            HStack(spacing: 2) {
                WebImage(url: Util.getImageUrl(from: record.logo)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .cornerRadius(5)
                        .frame(width: 20, height: 20)
                }

                Text(record.name ?? "未知")
                    .font(.system(size: 12))
            }
            .onTapGesture {
                let vc = BrowserWebViewController()
                vc.path = record.address ?? ""
                Util.topViewController().navigationController?.pushViewController(vc, animated: true)
            }
        }
        .padding(.top, 10)
    }

    @ViewBuilder
    private func historyView() -> some View {
        Group {
            if let historise, !historise.isEmpty {
                VStack(spacing: 10) {
                    HStack {
                        Text("搜索历史")
                            .font(.system(size: 14))
                            .opacity(0.5)

                        Spacer()

                        Image(systemName: "trash.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                            .onTapGesture {
                                showingDeleteAlert = true
                            }
                            .alert(isPresented: $showingDeleteAlert) {
                                Alert(
                                    title: Text("删除历史记录"),
                                    message: Text("您确定要删除所有历史记录吗？"),
                                    primaryButton: .destructive(Text("删除")) {
                                        deleteHistoryRecords()
                                    },
                                    secondaryButton: .cancel()
                                )
                            }
                    }

                    if !S.Config.openNoTrace {
                        FlowLayout(items: historise) { item in
                            HStack {
                                Text(item.title ?? "")
                                    .font(.system(size: 14))
                                    .onTapGesture {
                                        if let address = recordStore.selectedEngine.address,
                                           let keyword = recordStore.selectedEngine.keyword,
                                           let value = item.title {
                                            recordStore.content = value

                                            let vc = BrowserWebViewController()
                                            vc.path = address + "/" + keyword + value
                                            Util.topViewController().navigationController?.pushViewController(vc, animated: true)
                                        }
                                    }
                            }
                            .frame(minWidth: 20)
                        }
                    } else {
                        Text("无痕浏览时,浏览器不会保存你访问过的页面和搜索历史")
                            .font(.system(size: 12))
                            .opacity(0.5)
                            .padding(.all, 10)
                    }
                }
                .padding(.top, 10)
            } else {
                EmptyView()
            }
        }
    }

    @ViewBuilder
    private func RankingPageView() -> some View {
        Group {
            if let recors = recors, !recors.isEmpty {
                VStack(alignment: .leading) {
                    Text("热搜榜")
                        .font(.system(size: 14))
                        .opacity(0.5)
                    ForEach(Array(recors.enumerated()), id: \.element) { index, model in
                        VStack {
                            HStack {
                                Text("\(index + 1)")
                                Text(model.keyword ?? "")

                                Spacer()

                                Text(model.formattedSearchIndex)
                                    .foregroundColor(.red)

                                if let marker = model.marker, !marker.isEmpty {
                                    Text(marker)
                                        .font(.system(size: 12))
                                        .foregroundColor(.white)
                                        .frame(width: 20, height: 20)
                                        .background(Color.red)
                                        .cornerRadius(3)
                                        .padding(.leading, 10)
                                } else {
                                    Color.clear
                                        .frame(width: 20, height: 20)
                                        .padding(.leading, 10)
                                }
                            }
                            .font(.system(size: 14, weight: .medium))
                            .opacity(0.6)
                            .padding(.vertical, 8)
                            .onTapGesture {
                                if let address = recordStore.selectedEngine.address,
                                   let keyword = recordStore.selectedEngine.keyword,
                                   let value = model.keyword {
                                    recordStore.content = value

                                    let vc = BrowserWebViewController()
                                    vc.path = address + "/" + keyword + value
                                    Util.topViewController().navigationController?.pushViewController(vc, animated: true)
                                }
                            }

                            Divider()
                        }
                    }
                }

            } else {
                EmptyView()
            }
        }
        .padding(.top, 20)
    }
}

extension SearchView {
    private func deleteHistoryRecords() {
        historise?.removeAll()
        DBaseManager.share.deleteFromDb(fromTable: S.Table.searchHistory)
    }
}
