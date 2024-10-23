//
//  MarketDetailView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/22.
//

import SwiftUI

struct MarketDetailView: View {
    var model = MarketModel()
    @ObservedObject var viewModel = HomeViewModel()
    @StateObject var countdownTimer = CountdownTimer()

    var body: some View {
        VStack {
            topView()
            Spacer()
            bottomView()
        }
        .padding(.horizontal, 16)
        .onAppear {
            if let limitTime = model.template?.limitTime, model.doInfo != nil {
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
                Text("\(model.template?.template?.getDay ?? 0)天")
                    .font(.system(size: 30))
                    .foregroundColor(.white)

                Text("畅想VPN")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(.top, 5)

                Text("在邀请\(model.template?.template?.shareUserCount ?? 0)人,直接免费拿")
                    .font(.system(size: 12))
                    .padding(.top, 5)

                if model.template?.limitTime != nil && model.doInfo != nil {
                    Text(formatTime(countdownTimer.remainingTime))
                        .font(.system(size: 14))
                }
            }
            .padding(.top, 20)

            HStack(spacing: 10) {
                ForEach(0 ..< (model.template?.template?.shareUserCount ?? 0), id: \.self) { _ in
                    Image("convite")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }
            }
            .padding(.top, 30)
            .padding(.bottom, 20)
        }
        .padding(.top, 10)
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
                        shareAction()
                    }
                } label: {
                    Text("分享链接")
                        .frame(maxWidth: .infinity)
                }
            }
            .font(.system(size: 14))
            .foregroundColor(.white)
            .padding(.vertical, 15)
            .background(Color.blue)
            .cornerRadius(25)
        }
        .padding(.bottom, 20)
    }

    private func shareAction() {
        DispatchQueue.global().async {
            guard let shareURL = URL(string: viewModel.shareUrl) else {
                return
            }

            var activityItems: [Any]
            if #available(iOS 17, *) {
                activityItems = [shareURL as Any]
            } else {
                activityItems = [CustomShareItem(shareURL: shareURL, shareText: Util.appName(), shareImage: UIImage.icon ?? .init()) as Any]
            }
            DispatchQueue.main.async {
                let vc = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
                vc.modalPresentationStyle = .fullScreen
                if let popoverController = vc.popoverPresentationController {
                    popoverController.sourceView = Util.topViewController().view
                    popoverController.sourceRect = CGRect(x: Util.topViewController().view.bounds.midX, y: Util.topViewController().view.bounds.midY, width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                }
                Util.topViewController().present(vc, animated: true, completion: nil)

                vc.completionWithItemsHandler = { _, _, _, _ in }
            }
        }
    }
}

extension MarketDetailView {
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let days = Int(timeInterval) / 86400
        let hours = (Int(timeInterval) % 86400) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60

        if days > 0 {
            return String(format: "%02d天 %02d:%02d:%02d", days, hours, minutes, seconds)
        } else if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

struct GridImageView: View {
    var itemCount: Int
    var imageName: String
    var imageSize: CGFloat = 30
    var spacing: CGFloat = 10

    var body: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let columnsCount = Int((totalWidth + spacing) / (imageSize + spacing))

            LazyVGrid(columns: Array(repeating: GridItem(.fixed(imageSize), spacing: spacing), count: columnsCount), spacing: spacing) {
                ForEach(0 ..< itemCount, id: \.self) { _ in
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageSize, height: imageSize)
                }
            }
        }
        .frame(height: 100)
    }
}
