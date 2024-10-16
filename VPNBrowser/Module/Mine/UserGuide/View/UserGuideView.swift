//
//  UserGuideView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/16.
//

import Kingfisher
import SwiftUI

struct UserGuideView: View {
    @State private var userGuideData: [UserGuideResponse] = []

    let itemSpacing: CGFloat = 16
    let columnsCount = 3

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(userGuideData, id: \.id) { section in
                    if let records = section.record, !records.isEmpty {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(section.title ?? "")
                                    .font(.headline)
                                    .padding(.leading, 16)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: itemSpacing), count: columnsCount), spacing: itemSpacing) {
                                ForEach(records, id: \.id) { model in
                                    let itemWidth = (Util.deviceWidth - (itemSpacing * CGFloat(columnsCount + 1)) - 32) / CGFloat(columnsCount)

                                    VStack {
                                        KFImage(Util.getCompleteImageUrl(from: model.icon))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: itemWidth * 0.5, height: itemWidth * 0.5)

                                        Text(model.title ?? "")
                                            .font(.system(size: 14))
                                        Text(model.subtitle ?? "")
                                            .font(.system(size: 12))
                                            .opacity(0.5)
                                    }
                                    .frame(width: itemWidth, height: itemWidth)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(color: .gray.opacity(0.5), radius: 5)
                                    .onTapGesture {
                                        let vc = TextDisplayViewController()
                                        vc.title = model.title
                                        vc.content = model.content
                                        Util.topViewController().navigationController?.pushViewController(vc, animated: true)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .onAppear {
            APIProvider.shared.request(.userGuidePage, model: UserGuideResponse.self) { result in
                switch result {
                case let .success(model):
                    if let record = model.record {
                        let groupedData = Dictionary(grouping: record) { $0.classifyName ?? "Unknown" }
                        let classifiedData = groupedData.map { key, value in
                            UserGuideResponse(title: key, record: value)
                        }
                        userGuideData = classifiedData
                    }
                case let .failure(error):
                    print("Request failed with error: \(error)")
                }
            }
        }
    }
}

#Preview {
    UserGuideView()
}
