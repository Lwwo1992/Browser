//
//  VipView.swift
//  Browser
//
//  Created by xyxy on 2024/10/22.
//

import SDWebImageSwiftUI
import SwiftUI

struct VipView: View {
    @StateObject var viewModel = LoginManager.shared
    @StateObject var vipViewModel = VipViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                topView()
                contentView()
                bottomView()
            }
            .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private func topView() -> some View {
        HStack(alignment: .top) {
            WebImage(url: Util.getImageUrl(from: viewModel.userInfo.headPortrait)) { image in
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
                HStack {
                    Text(viewModel.userInfo.name ?? "游客")
                        .font(.system(size: 16))
                    Group {
                        if let vipCardVO = viewModel.userInfo.vipCardVO, let model = vipCardVO.first {
                            Text(model.name)
                                .font(.system(size: 12))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(Color.yellow)
                                .cornerRadius(6)
                        }
                    }
                }

                Group {
                    if let vipCardVO = viewModel.userInfo.vipCardVO, !vipCardVO.isEmpty {
                        ForEach(vipCardVO) { model in
                            if let vipExpireTime = model.vipExpireTime {
                                Text("\(model.name): \(model.validType == 2 ? "永久会员" : vipExpireTime.formatted)")
                            }
                        }
                    } else {
                        Text("开通会员,畅想上网")
                    }
                }
                .font(.system(size: 12))
                .opacity(0.5)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }

    @ViewBuilder
    private func contentView() -> some View {
        Group {
            if !vipViewModel.vipCards.isEmpty {
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(vipViewModel.vipCards) { model in
                            ZStack {
                                VStack(spacing: 8) {
                                    Text(model.name)
                                        .font(.system(size: 14))
                                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                                        Text("¥")
                                            .font(.system(size: 10))

                                        if model.isDiscounted {
                                            Text(model.payPrice)
                                                .font(.system(size: 25, weight: .medium))

                                            Text("¥\(model.originalPrice)")
                                                .font(.system(size: 10))
                                                .strikethrough()
                                                .padding(.leading, 5)
                                        } else {
                                            Text(model.payPrice)
                                                .font(.system(size: 25, weight: .medium))
                                        }
                                    }
                                    .foregroundColor(Color(hex: 0xDFB348))
                                    Text(model.validType == 2 ? "永久会员" : "有效期\(model.day)天")
                                        .font(.system(size: 12))
                                        .opacity(0.5)
                                }
                                .padding(.vertical, 25)
                                .padding(.horizontal, 15)
                                .background(vipViewModel.selectedItem == model ? Color(hex: 0xEBE6D5) : Color.white)
                                .cornerRadius(10)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(vipViewModel.selectedItem == model ? Color(hex: 0xDFB34A) : Color.clear, lineWidth: 2)
                                }
                                .onTapGesture {
                                    vipViewModel.selectedItem = model
                                }

                                if model.isDiscounted {
                                    ZStack {
                                        Text("限时优惠")
                                            .font(.system(size: 10))
                                            .foregroundColor(.white)
                                            .padding(5)
                                            .background(Color.red)
                                            .cornerRadius(5, corners: [.topLeft, .bottomRight])
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                    .padding([.leading, .top], 1)
                                }
                            }
                            .padding(.all, 2)
                        }
                    }
                }
            } else {
                Text("展无会员卡可购买")
                    .font(.system(size: 14))
                    .opacity(0.5)
                    .padding(.horizontal, 15)
            }
        }
        .onAppear {
            vipViewModel.fetchVipCardPage()
        }
    }

    @ViewBuilder
    private func bottomView() -> some View {
        VStack {
            Button {
                vipViewModel.pay()
            } label: {
                Text(!vipViewModel.vipCards.isEmpty ? "确认协议并立即¥\(vipViewModel.payPrice)购买" : "无卡可买")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(!vipViewModel.vipCards.isEmpty ? Color(hex: 0xF5CE63) : .gray.opacity(0.3))
                    .cornerRadius(20)
            }
            .disabled(vipViewModel.vipCards.isEmpty)

            Text("开通Vip即代表接受《会员服务协议》")
                .font(.system(size: 12))
                .opacity(0.5)

            if !vipViewModel.vipCards.isEmpty {
                VStack {
                    HStack(spacing: 0) {
                        Text("VIP")
                            .foregroundColor(.yellow)
                        Text("特权")
                    }
                    .font(.system(size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
                    .padding(.leading, 16)

                    specialItem()
                }
                .background(Color.white)
                .cornerRadius(10)
                .padding(.top, 20)
            }
        }
    }

    @ViewBuilder
    private func specialItem() -> some View {
        if let vipRights = vipViewModel.selectedItem.vipRights {
            LazyVStack {
                ForEach(vipRights) { model in
                    HStack {
                        WebImage(url: Util.getImageUrl(from: model.icon)) { image in
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
                            Text(model.name)
                                .font(.system(size: 16))
                            Text(model.des)
                                .font(.system(size: 12))
                                .opacity(0.5)
                        }
                    }
                    .padding(.horizontal, 10)
                    .frame(height: 80)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: 0xFCF4E3))
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
    }
}

//
// #Preview {
//    VipView()
// }
