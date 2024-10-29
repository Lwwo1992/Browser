//
//  BrowseHistory.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/14.
//

import SDWebImageSwiftUI
import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var viewModel: HistoryViewModel
    @State private var showingDeleteAlert = false
    @State private var selctedModel = HistoryModel()

    var body: some View {
        Group {
            if !viewModel.recordData.isEmpty {
                VStack {
                    contentView()
                    OperateBottomView()
                }
            } else {
                Text("暂无数据")
                    .font(.system(size: 16))
            }
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("删除记录"),
                message: Text("您确定要删除此记录吗？"),
                primaryButton: .destructive(Text("删除")) {
                    viewModel.deleteRecord(selctedModel)
                },
                secondaryButton: .cancel()
            )
        }
    }

    @ViewBuilder
    private func contentView() -> some View {
        ScrollView {
            LazyVStack {
                let groupedHistory = viewModel.recordData.groupedByDate()
                let sortedKeys = groupedHistory.keys.sorted(by: { $0 > $1 })

                ForEach(sortedKeys, id: \.self) { date in
                    let dateString = date.isToday ? "今天" : date.formattedDateString()

                    Text(dateString)
                        .font(.system(size: 14))
                        .padding(.leading, 10)
                        .padding(.vertical, 5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.2))

                    ForEach(groupedHistory[date]!, id: \.self) { model in
                        historyItemView(for: model)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func historyItemView(for model: HistoryModel) -> some View {
        VStack {
            HStack(spacing: 10) {
                if viewModel.isEdit {
                    Image(systemName: !model.isSelected ? "circle" : "checkmark.circle")
                        .onTapGesture {
                            model.isSelected.toggle()
                            viewModel.updateSelectedArray(for: model)
                        }
                }

                WebImage(url: URL(string: model.pageLogo ?? "")) { Image in
                    Image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                } placeholder: {
                    Image(systemName: "network")
                        .font(.system(size: 16))
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(model.title ?? "")
                        .font(.system(size: 16))
                    Text(model.address ?? "")
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
            .frame(height: 50)

            Divider()
        }
        .padding(.horizontal, 16)
        .background(Color(hex: 0xF8F5F5))
        .onTapGesture {
            let vc = BrowserWebViewController()
            vc.path = model.address ?? ""
            Util.topViewController().navigationController?.pushViewController(vc, animated: true)
        }
        .onLongPressGesture {
            selctedModel = model
            showingDeleteAlert = true
            debugPrint("-----")
        }
    }
}
