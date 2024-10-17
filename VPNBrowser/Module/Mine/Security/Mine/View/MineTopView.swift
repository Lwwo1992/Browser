//
//  MineTopView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/8.
//

import Kingfisher
import SwiftUI

struct MineTopView: View {
    @ObservedObject var loginManager = LoginManager.shared
    @State private var historyNumber: String = "0"
    @State private var collectNumber: String = "0"
    @State private var downloadNumber: String = "0"

    var body: some View {
        VStack {
            HStack {
                if let userHead = loginManager.loginInfo?.userHead {
                    KFImage(URL(string: userHead))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
//                        .placeholder {
//                            Image("default_image") // 替换为你项目中的默认图片名
//                                .resizable()
//                                .scaledToFill()
//                                .frame(width: 40, height: 40)
//                                .clipShape(Circle())
//                        }
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(loginManager.loginInfo?.account ?? "游客登录")
                        .font(.system(size: 18))
                        .font(.system(size: 18))
                    Text("已经陪伴你8天")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                .onTapGesture {
                    if S.Config.isLogin {
                        Util.topViewController().navigationController?.pushViewController(LoginViewController(), animated: true)
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

#Preview {
    MineTopView()
}
