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
        .frame(maxHeight: .infinity, alignment: .top)
        .onAppear {
            viewModel.fetchMarketList()
        }
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
        .onTapGesture {
            let vc = MarketDetailViewController()
            vc.title = viewModel.marketModel.name
            vc.model = viewModel.marketModel
            Util.topViewController().navigationController?.pushViewController(vc, animated: true)
        }

        HStack(spacing: 10) {
            ForEach(0 ..< (viewModel.marketModel.template?.template?.shareUserCount ?? 0), id: \.self) { _ in
                Image("convite")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            }
        }
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
                            Text("邀好友赚\(model.template?.template?.getDay ?? 0)天VPN福利(0/\(model.template?.template?.shareUserCount ?? 0))")
                                .font(.system(size: 14))
                                .opacity(0.5)
                        }

                        Spacer()

                        Button {
                            if model.userType == [2] && LoginManager.shared.info.userType == .visitor {
                                Util.topViewController().navigationController?.pushViewController(LoginViewController(), animated: true)
                            } else {
                                let vc = MarketDetailViewController()
                                vc.title = model.name
                                vc.model = model
                                Util.topViewController().navigationController?.pushViewController(vc, animated: true)
                            }
                        } label: {
                            Text("在邀请\(model.template?.template?.shareUserCount ?? 0)人")
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
