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

                Text("在邀请\(model.template.details.shareUserCount)人,直接免费拿")
                    .font(.system(size: 12))
                    .padding(.top, 5)

                if model.template.limitTime != nil && model.doInfo != nil {
                    Text(Util.formatTime(countdownTimer.remainingTime))
                        .font(.system(size: 14))
                }
            }
            .padding(.top, 20)

            HStack(spacing: 10) {
                ForEach(0 ..< viewModel.visitorImages.count, id: \.self) { index in
                    WebImage(url: Util.getCompleteImageUrl(from: viewModel.visitorImages[index])) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                    } placeholder: {
                        Image("convite")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                    }
                }
            }
            .padding(.top, 30)
            .padding(.bottom, 20)
        }
        .padding(.top, 10)
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
                    viewModel.generaShareUrl(for: model.id) { url in
                        if let url, let image = Util.createQRCodeImage(content: url) {
                            Util.topViewController().popup.dialog {
                                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
                                imageView.image = image
                                return imageView
                            }
                        }
                    }
                } label: {
                    Text("扫码分享")
                        .frame(maxWidth: .infinity)
                }

                Button {
                    viewModel.generaShareUrl(for: model.id) { _ in
                        viewModel.shareAction()
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
