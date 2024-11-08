//
//  WebViewTab.swift
//  Browser
//
//  Created by xyxy on 2024/11/7.
//

import Foundation
import WebKit

public class WebViewTab: ObservableObject {
    @Published var webView: WKWebView
    var lastAccessed: Date
    var url: URL?
    var title: String?
    var imagePath: String?

    var expirationInterval: TimeInterval = 3600 // 缓存有效期，单位秒，默认1小时

    var imageURL: URL {
        guard let imagePath = imagePath else {
            return S.Files.imageURL
        }
        return S.Files.imageURL.appendingPathComponent(imagePath)
    }

    init(webView: WKWebView, url: URL?, title: String?) {
        lastAccessed = Date()
        self.webView = webView
        self.url = url
        self.title = title
    }

    // 检查缓存是否过期
    var isExpired: Bool {
        return Date().timeIntervalSince(lastAccessed) > expirationInterval
    }

    // 更新缓存时间
    func updateCacheTime() {
        lastAccessed = Date()
    }
}
