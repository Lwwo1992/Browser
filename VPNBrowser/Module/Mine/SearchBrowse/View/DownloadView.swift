//
//  DownloadManagerView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/16.
//

import Kingfisher
import SwiftUI

struct DownloadView: View {
    @ObservedObject var viewModel: DownloadViewModel

    var body: some View {
        if !viewModel.array.isEmpty {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible())], spacing: 20) {
                    ForEach(viewModel.array) { model in
                        DownloadRowView(model: model, viewModel: viewModel)
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, 6)
            }
            .background(Color.white)
        } else {
            Text("暂无数据")
                .font(.system(size: 16))
        }
    }
}

struct DownloadRowView: View {
    @ObservedObject var model: DownloadModel
    @ObservedObject var viewModel: DownloadViewModel

    var body: some View {
        HStack {
            if viewModel.isEdit {
                Image(systemName: !model.isSelected ? "circle" : "checkmark.circle")
                    .onTapGesture {
                        model.isSelected.toggle()
                        viewModel.updateSelectedArray(for: model)
                    }
            }

            KFImage(URL(string: model.url))
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .cornerRadius(5)

            VStack(alignment: .leading) {
                Text(model.title)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text(Util.formatFileSize(model.size))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .padding(.leading, 10)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
    }
}
