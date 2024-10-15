//
//  BrowseHistory.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/14.
//

import Kingfisher
import SwiftUI

struct BrowseHistory: View {
    @EnvironmentObject var viewModel: FootprintViewModel
    @State private var historise: [HistoryModel]? = nil

    var body: some View {
        ScrollView {
            VStack {
                if let historise = historise, !historise.isEmpty {
                    let groupedHistory = historise.groupedByDate()
                    let sortedKeys = groupedHistory.keys.sorted(by: { $0 > $1 })

                    ForEach(sortedKeys, id: \.self) { date in
                        let dateString = date.isToday ? "今天" : date.formattedDateString()

                        Text(dateString)
                            .font(.system(size: 14))
                            .padding(.leading, 10)
                            .padding(.vertical, 5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.5))

                        ForEach(groupedHistory[date]!, id: \.self) { model in
                            VStack {
                                HStack(spacing: 10) {
                                    if viewModel.selectedSegmentIndex == 1 {
                                        if let path = model.pageLogo, let url = URL(string: path) {
                                            KFImage(url)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 20, height: 20)
                                        }

                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(model.title ?? "")
                                                .font(.system(size: 16))
                                            Text(model.path ?? "")
                                                .font(.system(size: 12))
                                                .opacity(0.5)
                                        }

                                    } else {
                                        Text(model.path ?? "")
                                            .font(.system(size: 12))
                                            .opacity(0.5)
                                    }

                                    Spacer()

                                    Text(Util.formattedTime(from: model.timestamp))
                                        .font(.system(size: 12))
                                        .opacity(0.5)
                                }
                                .font(.system(size: 14, weight: .medium))
                                .opacity(0.6)
                                .frame(height: viewModel.selectedSegmentIndex == 1 ? 50 : 30)

                                Divider()
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
            }
            .onAppear {
                loadHistory()
            }
            .onChange(of: viewModel.selectedSegmentIndex) { _ in
                loadHistory()
            }
        }
    }

    private func loadHistory() {
        if var historise, !historise.isEmpty {
            historise.removeAll()
        }

        historise = DBaseManager.share.qureyFromDb(
            fromTable: viewModel.selectedSegmentIndex == 0 ? S.Table.collect : S.Table.browseHistory,
            cls: HistoryModel.self
        )?.reversed()
    }
}

extension Date {
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }

    func formattedDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
}

extension Array where Element == HistoryModel {
    func groupedByDate() -> [Date: [HistoryModel]] {
        let calendar = Calendar.current
        var groupedHistory: [Date: [HistoryModel]] = [:]

        for history in self {
            let date = Date(timeIntervalSince1970: history.timestamp)
            let dateWithoutTime = calendar.startOfDay(for: date)

            if groupedHistory[dateWithoutTime] != nil {
                groupedHistory[dateWithoutTime]?.append(history)
            } else {
                groupedHistory[dateWithoutTime] = [history]
            }
        }

        return groupedHistory
    }
}
