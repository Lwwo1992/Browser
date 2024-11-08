//
//  WebViewTabManager.swift
//  Browser
//
//  Created by xyxy on 2024/11/7.
//

import SwiftUI
import UIKit
import WebKit

class WebViewTabManager: ObservableObject {
    @Published var tabs: [WebViewTab] = [] // 存储所有标签

    private var selectedTabIndex: Int? // 当前选中的标签

    // 获取当前选中的 tab
    var selectedTab: WebViewTab? {
        guard let index = selectedTabIndex else { return nil }
        return tabs[index]
    }

    // 添加标签页
    func addTab(url: URL?, title: String?) {
        let webView = WKWebView()
        let newTab = WebViewTab(webView: webView, url: url, title: title)
        tabs.append(newTab)
        selectedTabIndex = tabs.count - 1 // 切换到新标签
    }

    // 切换标签
    func selectTab(at index: Int) {
        guard index < tabs.count else { return }
        selectedTabIndex = index
    }

    // 移除标签页
    func removeTab(at index: Int) {
        guard index < tabs.count else { return }
        if let url = tabs[index].url {
            DBaseManager.share.deleteFromDb(fromTable: S.Table.bookmark, where: url.absoluteString)
        }
        tabs.remove(at: index)
    }

    // 检查缓存是否过期，并显示图片
    func shouldDisplayPlaceholder(for tab: WebViewTab) -> Bool {
        return tab.isExpired
    }
}
