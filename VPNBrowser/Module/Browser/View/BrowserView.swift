//
//  BrowserView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/10.
//

import SwiftUI

struct BrowserView: View {
    var body: some View {
        VStack {
            HStack {
                searchBar
                notificationBadge
            }
            .padding(.horizontal, 16)
            WebView(urlString: S.config.defalutUrl)
                .frame(maxHeight: .infinity)
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")

            Text("全网搜索")
                .font(.system(size: 14))
                .opacity(0.5)

            Spacer()
        }
        .padding(.horizontal, 10)
        .frame(height: 35)
        .background(
            Color.white
                .cornerRadius(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray, lineWidth: 1)
                )
        )
        .onTapGesture {
            Util.topViewController().navigationController?.pushViewController(SearchViewController(), animated: true)
        }
    }

    private var notificationBadge: some View {
        Rectangle()
            .fill(Color.white)
            .frame(width: 25, height: 25)
            .cornerRadius(2)
            .overlay(
                Text("3")
                    .font(.system(size: 12))
                    .foregroundColor(.black)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color.gray, lineWidth: 1)
            )
    }
}

#Preview {
    BrowserView()
}
