//
//  SearchView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/10.
//
import Kingfisher
import SwiftUI

struct SearchView: View {
    @ObservedObject var recordStore: RecordStore
    /// 热搜数据
    @State private var recors: [RankingModel]? = nil
    /// 搜索历史数据
    @State private var historise: [HistoryModel]? = nil

    @State private var showingDeleteAlert = false

    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 5)

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
            historise = DBaseManager.share.qureyFromDb(fromTable: S.Table.searchHistory, cls: HistoryModel.self)
        }
    }

    @ViewBuilder
    private func topView() -> some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(self.recordStore.records, id: \.name) { record in
                HStack(spacing: 2) {
                    KFImage(Util.getCompleteImageUrl(from: record.logo))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)

                    Text(record.name ?? "未知")
                        .font(.system(size: 12))
                        .frame(maxWidth: 55, alignment: .leading)
                        .frame(width: 60)
                }
                .padding()
            }
        }
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

                    ForEach(historise.chunked(into: 2), id: \.self) { row in
                        HStack {
                            ForEach(row, id: \.id) { item in
                                Text(item.title ?? "")
                                    .font(.system(size: 14))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .cornerRadius(5)
                                    .onTapGesture {
                                        recordStore.content = item.title ?? ""
                                    }
                            }
                        }
                    }
                }
                .padding(.top, 20)
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

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
