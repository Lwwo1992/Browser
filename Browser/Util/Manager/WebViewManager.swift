//
//  WebViewManager.swift
//  Browser
//
//  Created by xyxy on 2024/11/14.
//

import UIKit
import WebKit

protocol WebViewDelegate: AnyObject {
    func webViewDidStartLoading(_ webView: WKWebView)
    func webViewDidFinishLoading(_ webView: WKWebView)
    func webView(_ webView: WKWebView, didFailToLoadWithError error: Error)
}

extension WebViewDelegate {
    func webViewDidStartLoading(_ webView: WKWebView) {}
    func webViewDidFinishLoading(_ webView: WKWebView) {}
    func webView(_ webView: WKWebView, didFailToLoadWithError error: Error) {}
}

class WebViewManager: NSObject {
    static let shared = WebViewManager()

    weak var delegate: WebViewDelegate?

    override private init() {
        super.init()
    }

    // 创建 WebView
    func createWebView() -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        return webView
    }

    // 加载 URL
    func loadURL(_ url: URL, in webView: WKWebView) {
        let request = URLRequest(url: url)
        webView.load(request)
    }

    // 加载 HTML 字符串
    func loadHTMLString(_ htmlString: String, in webView: WKWebView) {
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
}

// MARK: - WKNavigationDelegate Methods

extension WebViewManager: WKNavigationDelegate, WKUIDelegate {
    // 页面开始加载
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        delegate?.webViewDidStartLoading(webView)
    }

    // 页面加载完成
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        delegate?.webViewDidFinishLoading(webView)
    }

    // 页面加载失败
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        delegate?.webView(webView, didFailToLoadWithError: error)
    }
}
