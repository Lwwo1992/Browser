//
//  WebView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/14.
//

import JFPopup
import SwiftUI

struct BrowserWebView: View {
    @State private var isSheetPresented = false
    @ObservedObject var viewModel: WebViewViewModel

    var body: some View {
        VStack {
            searchBar()

            WebView(viewModel: viewModel) { model in
                DBaseManager.share.insertToDb(objects: [model], intoTable: S.Table.browseHistory)
            }

            bottomView()
        }
    }

    @ViewBuilder
    private func searchBar() -> some View {
        HStack {
            Image(systemName: "lock.shield")
                .font(.system(size: 20))

            Text(verbatim: viewModel.urlString)
                .font(.system(size: 14))
                .foregroundColor(.black)
                .opacity(0.5)

            Spacer()

            Image(systemName: "star.fill")
                .font(.system(size: 14))
                .foregroundColor(.yellow)
        }
        .frame(height: 40)
        .padding(.horizontal, 10)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
        )
        .onTapGesture {
            Util.topViewController().navigationController?.popViewController(animated: true)
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func bottomView() -> some View {
        HStack {
            Image(.backIndicator)
                .onTapGesture {
                    Util.topViewController().navigationController?.popViewController(animated: true)
                }

            Spacer()

            Image(systemName: "arrow.trianglehead.clockwise.rotate.90")
                .rotationEffect(Angle(degrees: viewModel.refresh ? 360 : 0))
                .onTapGesture {
                    withAnimation {
                        withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                            viewModel.refresh = true
                        }
                    }
                }

            Spacer()

            RoundedRectangle(cornerRadius: 2)
                .stroke(Color.black, lineWidth: 1)
                .frame(width: 15, height: 15)
                .background(Color.white)

            Spacer()

            Image(systemName: "ellipsis")
                .foregroundColor(.black)
                .onTapGesture {
                    Util.topViewController().popup.bottomSheet {
                        let v = BrowserWebBottomSheet(frame: CGRect(x: 0, y: 0, width: Util.deviceWidth, height: 200))
                        return v
                    }
                }
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 30)
        .background(Color(hex: 0xF8F5F5))
    }
}
