//
//  MarketDetailView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/22.
//

import SDWebImageSwiftUI
import SwiftUI

struct MarketDetailView: View {
    var model = MarketModel()
    @ObservedObject var viewModel = HomeViewModel()
    @StateObject var countdownTimer = CountdownTimer()

    var body: some View {
        VStack {
            topView()
            bottomView()
            Spacer()
        }
        .padding(.horizontal, 16)
        .onAppear {
            if let limitTime = model.template.limitTime, model.doInfo != nil {
                countdownTimer.resetCountdown(to: 60 * 60 * Double(limitTime))
                countdownTimer.startCountdown()
            }
        }
        .onDisappear {
            countdownTimer.stopTimer()
        }
    }

    @ViewBuilder
    private func topView() -> some View {
        VStack {
            Text("已有\(model.hasJoinCount)参与")
                .font(.system(size: 12))
                .opacity(0.5)
                .padding(.top, 5)

            VStack(spacing: 5) {
                Text("\(model.template.details.getDay)天")
                    .font(.system(size: 30))
                    .foregroundColor(.white)

                Text("畅想VPN")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(.top, 5)

                Text("在邀请\(viewModel.remainingInviteCount(for: model))人,直接免费拿")
                    .font(.system(size: 12))
                    .padding(.top, 5)

                if model.template.limitTime != nil && model.doInfo != nil {
                    Text(Util.formatTime(countdownTimer.remainingTime))
                        .font(.system(size: 14))
                }
            }
            .padding(.top, 20)

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
                                    if model.userType == [2] && (LoginManager.shared.info.userType == .visitor || LoginManager.shared.info.token.isEmpty) {
                                        Util.topViewController().navigationController?.pushViewController(LoginViewController(), animated: true)
                                    } else {
                                        viewModel.marketModel = model
                                        viewModel.showShareBottomSheet.toggle()
                                    }
                                }
                        } else {
                            WebImage(url: Util.getCompleteImageUrl(from: viewModel.visitorImages[index])) { image in
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
            .padding(.top, 20)
        }
        .padding(.top, 20)
        .onAppear {
            let shareUserCount = model.template.details.shareUserCount
            viewModel.visitorImages = Array(repeating: "convite", count: shareUserCount)

            if let doInfo = model.doInfo {
                for (index, id) in doInfo.hasShareUserIds.prefix(shareUserCount).enumerated() {
                    viewModel.visitorAccess(id: id, index: index)
                }
            }
        }
    }

    @ViewBuilder
    private func bottomView() -> some View {
        HStack(spacing: 20) {
            Group {
                Button {
                    if model.userType == [2] && (LoginManager.shared.info.userType == .visitor || LoginManager.shared.info.token.isEmpty) {
                        Util.topViewController().navigationController?.pushViewController(LoginViewController(), animated: true)
                    } else {
                        viewModel.generaShareUrl(for: model.id) { url in
                            if let url, let image = Util.createQRCodeImage(content: url) {
                                Util.topViewController().popup.dialog {
                                    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
                                    imageView.image = image
                                    return imageView
                                }
                            }
                        }
                    }

                } label: {
                    Text("扫码分享")
                        .frame(maxWidth: .infinity)
                }

                Button {
                    if model.userType == [2] && (LoginManager.shared.info.userType == .visitor || LoginManager.shared.info.token.isEmpty) {
                        Util.topViewController().navigationController?.pushViewController(LoginViewController(), animated: true)
                    } else {
                        viewModel.generaShareUrl(for: model.id) { _ in
                            viewModel.shareAction()
                        }
                    }

                } label: {
                    Text("分享链接")
                        .frame(maxWidth: .infinity)
                }
            }
            .font(.system(size: 14))
            .foregroundColor(.black)
            .padding(.vertical, 15)
            .background(Color.white)
            .cornerRadius(25)
        }
        .padding(.top, 20)
    }
}
