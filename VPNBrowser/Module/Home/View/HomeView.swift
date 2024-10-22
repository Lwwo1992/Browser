//
//  HomeView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/12.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        VStack(spacing: 0) {
            topView()
            bottomView()
        }
        .frame(height: .infinity, alignment: .top)
    }

    @ViewBuilder
    private func topView() -> some View {
        Text(viewModel.marketModel.name)
            .font(.system(size: 16))
            .foregroundColor(.white)
        Text("已有\(viewModel.marketModel.hasJoinCount)参与")
            .font(.system(size: 12))
            .opacity(0.5)
            .padding(.top, 5)

        VStack(spacing: 5) {
            Text("\(viewModel.marketModel.template?.template?.getDay ?? 0)天")
                .font(.system(size: 30))
                .foregroundColor(.white)

            Text("畅想VPN")
                .font(.system(size: 14))
                .foregroundColor(.white)
                .padding(.top, 5)

            Text("在邀请\(viewModel.marketModel.template?.template?.shareUserCount ?? 0)人,直接免费拿")
                .font(.system(size: 12))
                .padding(.top, 5)
        }
        .padding(.top, 20)

        HStack(spacing: 10) {
            ForEach(0 ..< 5) { _ in
                Image("convite")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            }
        }
        .frame(width: 210)
        .frame(height: 50)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(20)
        .padding(.horizontal, 16)
        .padding(.top, 30)
        .padding(.bottom, 20)
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
                            Text("邀好友赚\(model.hasJoinCount)天VPN福利(0/1)")
                                .font(.system(size: 14))
                                .opacity(0.5)
                        }

                        Spacer()

                        Button {
                            let vc = MarketDetailViewController()
                            vc.viewModel = viewModel
                            Util.topViewController().navigationController?.pushViewController(vc, animated: true)
                        } label: {
                            Text("在邀请\(viewModel.marketModel.template?.template?.shareUserCount ?? 0)人")
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
