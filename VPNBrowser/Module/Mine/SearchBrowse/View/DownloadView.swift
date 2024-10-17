//
//  DownloadManagerView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/16.
//

import Kingfisher
import SwiftUI

struct DownloadView: View {
    // checkmark.circle.platter
    // circle
    @ObservedObject var viewModel: DownloadViewModel

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 20) {
                ForEach(viewModel.array) { model in
                    HStack {
                        if viewModel.isEdit {
                            Image(systemName: "circle")
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
                            .onTapGesture {
                                if let fileUrl = URL(string: model.url) {
                                    viewModel.selectedFileUrl = fileUrl
                                }
                            }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                }
                .padding(.horizontal, 16)
            }
            .padding(.top, 6)
        }
        .background(Color.white)
    }
}