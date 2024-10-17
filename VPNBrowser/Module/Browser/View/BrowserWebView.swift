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
    @State private var isCollect = false
    @ObservedObject var viewModel: WebViewViewModel

    var body: some View {
        VStack {
            searchBar()

            WebView(viewModel: viewModel) { model in
                if !S.Config.openNoTrace {
                    DBaseManager.share.insertToDb(objects: [model], intoTable: S.Table.browseHistory)
                }
            }

            bottomView()
        }
        .onAppear {
            if let array = DBaseManager.share.qureyFromDb(fromTable: S.Table.collect, cls: HistoryModel.self, where: HistoryModel.Properties.path == viewModel.urlString), !array.isEmpty {
                isCollect = true
            }
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
                .onTapGesture {
                    Util.topViewController().navigationController?.popViewController(animated: true)
                }

            Spacer()

            Image(systemName: isCollect ? "star.fill" : "star")
                .font(.system(size: 14))
                .foregroundColor(isCollect ? .yellow : .gray)
                .onTapGesture {
                    isCollect.toggle()

                    if isCollect {
                        let model = HistoryModel()
                        model.path = viewModel.urlString
                        DBaseManager.share.insertToDb(objects: [model], intoTable: S.Table.collect)
                    } else {
                        DBaseManager.share.deleteFromDb(fromTable: S.Table.collect, where: HistoryModel.Properties.path == viewModel.urlString)
                    }
                }
        }
        .frame(height: 40)
        .padding(.horizontal, 10)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
        )
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

//            RoundedRectangle(cornerRadius: 2)
//                .stroke(Color.black, lineWidth: 1)
//                .frame(width: 15, height: 15)
//                .background(Color.white)
//
//            Spacer()

            Image(systemName: "ellipsis")
                .foregroundColor(.black)
                .onTapGesture {
                    viewModel.showBottomSheet.toggle()
                }
                .padding()
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 30)
        .background(Color(hex: 0xF8F5F5))
    }
}
