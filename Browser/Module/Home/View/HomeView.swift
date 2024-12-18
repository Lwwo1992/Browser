//
//  HomeView.swift
//  Browser
//
//  Created by xyxy on 2024/10/12.
//

import SDWebImageSwiftUI
import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @StateObject var countdownTimer = CountdownTimer()

    var body: some View {
        VStack(spacing: 0) {
            topView()
            bottomView()
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .onAppear {
            viewModel.fetchMarketList()
        }
        .onAppear {
            if let marketModel = viewModel.marketModel, let doInfo = marketModel.doInfo, let expireTime = doInfo.expireTime {
                let currentRemainingTime = expireTime - Date().timeIntervalSince1970 * 1000
                if currentRemainingTime > 0 {
                    countdownTimer.resetCountdown(to: currentRemainingTime / 1000)
                    countdownTimer.startCountdown()
                }
            }
        }
        .onDisappear {
            countdownTimer.stopTimer()
        }
        .padding(.top, Util.safeAreaInsets.top + 44)
    }

    @ViewBuilder
    private func topView() -> some View {
        if let marketModel = viewModel.marketModel {
            Text(marketModel.name)
                .font(.system(size: 16))
                .foregroundColor(.white)
            Text("已有\(marketModel.hasJoinCount)参与")
                .font(.system(size: 12))
                .opacity(0.5)
                .padding(.top, 5)

            VStack(spacing: 5) {
                Text("\(marketModel.template.details.getDay)天")
                    .font(.system(size: 30))
                    .foregroundColor(.white)

                Text("畅想上网")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(.top, 5)

                Text("在邀请\(marketModel.template.details.shareUserCount)人,直接免费拿")
                    .font(.system(size: 12))
                    .padding(.top, 5)

                if let doInfo = marketModel.doInfo, let expireTime = doInfo.expireTime {
                    let currentRemainingTime = expireTime - Date().timeIntervalSince1970 * 1000
                    if currentRemainingTime > 0 {
                        Text(Util.formatTime(countdownTimer.remainingTime))
                            .font(.system(size: 14))
                    } else {
                        Text("限时活动已结束")
                            .font(.system(size: 14))
                    }
                }
            }
            .padding(.top, 20)
            .onTapGesture {
                let vc = MarketDetailViewController()
                vc.title = marketModel.name
                vc.model = marketModel
                Util.topViewController().navigationController?.pushViewController(vc, animated: true)
            }

            VStack {
                LazyVGrid(
                    columns: Array(
                        repeating: GridItem(.fixed(30), spacing: 10),
                        count: viewModel.visitorImages.count < 5 ? viewModel.visitorImages.count : 5
                    ),
                    alignment: .center,
                    spacing: 10
                ) {
                    ForEach(0 ..< (viewModel.showAllImages ? viewModel.visitorImages.count : min(viewModel.visitorImages.count, 10)), id: \.self) { index in
                        if viewModel.visitorImages[index] == "convite" {
                            Image("convite")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .onTapGesture {
                                    if marketModel.userType == [2] && (LoginManager.shared.info.userType == .visitor || LoginManager.shared.info.token.isEmpty) {
                                        Util.topViewController().navigationController?.pushViewController(LoginViewController(), animated: true)
                                    } else {
                                        viewModel.showShareBottomSheet.toggle()
                                    }
                                }
                        } else {
                            WebImage(url: Util.getImageUrl(from: viewModel.visitorImages[index])) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                            } placeholder: {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 30))
                            }
                        }
                    }
                }

                if viewModel.visitorImages.count > 10 {
                    HStack {
                        Spacer()
                        Button(action: {
                            viewModel.showAllImages.toggle()
                        }) {
                            Text(viewModel.showAllImages ? "收起" : "更多")
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 10)
                    }
                }
            }
            .padding(.top, 30)
            .padding(.bottom, 20)
            .onReceive(viewModel.$marketModel, perform: { model in
                if let model {
                    let shareUserCount = model.template.details.shareUserCount
                    viewModel.visitorImages = Array(repeating: "convite", count: shareUserCount)

                    if let doInfo = model.doInfo {
                        for (index, id) in doInfo.hasShareUserIds.prefix(shareUserCount).enumerated() {
                            viewModel.visitorAccess(id: id, index: index)
                        }
                    }
                }
            })
        } else {
            VStack(spacing: 10) {
                Image(.activityEmpty)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
                Text("暂无活动,尽情期待")
                    .font(.system(size: 14))
                    .opacity(0.5)
            }
            .frame(maxHeight: .infinity, alignment: .center)
        }
    }

    @ViewBuilder
    private func bottomView() -> some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.marketData) { model in
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(model.name)
                                .font(.system(size: 16))
                            Text("邀好友赚\(model.template.details.getDay)天上网福利(\(model.doInfo?.hasShareUserIds.count ?? 0)/\(model.template.details.shareUserCount))")
                                .font(.system(size: 14))
                                .opacity(0.5)
                        }

                        Spacer()

                        Button {
                            if let doInfo = model.doInfo, doInfo.hasShareUserIds.count ==
                                model.template.details.shareUserCount, !model.hasGet {
                                viewModel.getMarketReward(id: model.id)
                            } else {
                                let vc = MarketDetailViewController()
                                vc.title = model.name
                                vc.model = model
                                Util.topViewController().navigationController?.pushViewController(vc, animated: true)
                            }
                        } label: {
                            Text(viewModel.inviteStatus(for: model))
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .frame(width: 80, height: 30)
                                .background(Color.blue)
                                .cornerRadius(15)
                        }
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 80)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.gray.opacity(0.5), radius: 10, x: 0, y: 5)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// #Preview {
//    HomeView()
// }
