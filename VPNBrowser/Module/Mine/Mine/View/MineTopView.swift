//
//  MineTopView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/8.
//

import Kingfisher
import SDWebImageSwiftUI
import SwiftUI

struct MineTopView: View {
    @StateObject var viewModel = LoginManager.shared

    @State private var historyNumber: String = "0"
    @State private var collectNumber: String = "0"
    @State private var downloadNumber: String = "0"
    @State private var lowPrice: String = "0"

    var body: some View {
        VStack {
            HStack {
                WebImage(url: URL(string: viewModel.info.headPortrait)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } placeholder: {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 40))
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(viewModel.info.name ?? "立即登录")
                        .font(.system(size: 18))
                        .font(.system(size: 18))
                    Text("\(Util.appName())已经陪伴你\(viewModel.info.createTime.daysFromNow)天")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                .onTapGesture {
                    if LoginManager.shared.info.userType == .visitor {
                        Util.topViewController().navigationController?.pushViewController(LoginViewController(), animated: true)
                    } else {
                        Util.topViewController().navigationController?.pushViewController(SecurityViewController(), animated: true)
                    }
                }

                Spacer()

                Button {
                } label: {
                    Text("福利中心")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 5)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]),
                                           startPoint: .leading,
                                           endPoint: .trailing)
                                .cornerRadius(8)
                        )
                }
            }

            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("会员卡限时折扣")
                        .font(.system(size: 14))
                    Text("送免费使用vpn")
                        .font(.system(size: 12))
                        .opacity(0.5)
                }

                Spacer()

                Button {
                    Util.topViewController().navigationController?.pushViewController(VipViewController(), animated: true)
                } label: {
                    Text("最低\(lowPrice)/天")
                        .font(.system(size: 14))
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color(hex: 0xDFB348), Color.orange]), startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(15)
                        .foregroundColor(.white)
                }
                .onAppear {
                    APIProvider.shared.request(.getVipLowPrice, progress: { _ in }) { result in
                        switch result {
                        case let .success(response):
                            do {
                                if let jsonObject = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: Any],
                                   let price = jsonObject["data"] as? String {
                                    self.lowPrice = price
                                } else {
                                    print("未能解析 'data' 字段")
                                }
                            } catch {
                                print("Failed to parse JSON: \(error)")
                            }
                        case let .failure(error):
                            print("Request failed with error: \(error)")
                        }
                    }
                }
            }
            .padding(.top, 20)

            HStack {
                VStack(spacing: 5) {
                    Text(collectNumber)
                        .font(.system(size: 18))
                    Text("收藏")
                        .font(.system(size: 12))
                        .opacity(0.5)
                }
                .onTapGesture {
                    Util.topViewController().navigationController?.pushViewController(FootprintViewController(selectedSegmentIndex: 0), animated: true)
                }
                .onAppear {
                    let number = DBaseManager.share.qureyFromDb(fromTable: S.Table.collect, cls: HistoryModel.self)?.count ?? 0
                    if number >= 999 {
                        self.collectNumber = "999+"
                    } else {
                        self.collectNumber = "\(number)"
                    }
                }

                Spacer()

                VStack(spacing: 5) {
                    Text(historyNumber)
                        .font(.system(size: 18))
                    Text("历史")
                        .font(.system(size: 12))
                        .opacity(0.5)
                }
                .onAppear {
                    let number = DBaseManager.share.qureyFromDb(fromTable: S.Table.browseHistory, cls: HistoryModel.self)?.count ?? 0
                    if number >= 999 {
                        self.historyNumber = "999+"
                    } else {
                        self.historyNumber = "\(number)"
                    }
                }
                .onTapGesture {
                    Util.topViewController().navigationController?.pushViewController(FootprintViewController(selectedSegmentIndex: 1), animated: true)
                }

                Spacer()

                VStack(spacing: 5) {
                    Text(downloadNumber)
                        .font(.system(size: 18))
                    Text("下载")
                        .font(.system(size: 12))
                        .opacity(0.5)
                }
                .onTapGesture {
                    Util.topViewController().navigationController?.pushViewController(DownloadViewController(), animated: true)
                }
                .onAppear {
                    if let array = DBaseManager.share.qureyFromDb(fromTable: S.Table.download, cls: DownloadModel.self) {
                        let number = array.count
                        if number >= 999 {
                            self.downloadNumber = "999+"
                        } else {
                            self.downloadNumber = "\(number)"
                        }
                    }
                }
            }
            .padding(.vertical, 25)
            .padding(.horizontal, 24)
            .background(Color.white)
            .cornerRadius(10)
            .padding(.top, 20)
        }
    }
}

// #Preview {
//    MineTopView()
// }
