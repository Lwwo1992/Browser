//
//  WebView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/12.
//

import Combine
import SwiftUI
import WebKit

class WebViewViewModel: ObservableObject {
    @Published var urlString: String = ""
    @Published var refresh: Bool = true
    // 控制是否保存历史记录
    @Published var shouldSaveHistory: Bool = false
}

struct WebView: UIViewRepresentable {
    var urlString: String? = nil
    @ObservedObject var viewModel = WebViewViewModel()
    var onSaveHistory: ((HistoryModel) -> Void)? = nil

    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate {
        var parent: WebView
        var webView: WKWebView!

        private var timer: Timer?
        private var cancellables = Set<AnyCancellable>()
        private var mode = WKWebpagePreferences.ContentMode.mobile

        init(_ parent: WebView) {
            self.parent = parent
            super.init()

            parent.viewModel.$refresh
                .dropFirst()
                .sink { [weak self] isRefreshing in
                    guard let self, let url = URL(string: parent.viewModel.urlString) else { return }
                    if isRefreshing {
                        loadWebsite(url)
                    }
                }
                .store(in: &cancellables)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            withAnimation {
                parent.viewModel.refresh = false
            }

            let model = HistoryModel()
            model.title = webView.title
            model.path = webView.url?.absoluteString

            webView.evaluateJavaScript("document.querySelector('link[rel*=\"icon\"]').href") { result, error in
                if let logo = result as? String {
                    model.pageLogo = logo
                } else {
                    print("Failed to get logo: \(String(describing: error?.localizedDescription))")
                }

                self.parent.onSaveHistory?(model)
            }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("Failed to load webpage: \(error.localizedDescription)")
            withAnimation {
                parent.viewModel.refresh = false
            }
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
            preferences.preferredContentMode = mode
            decisionHandler(.allow, preferences)
        }

        private func loadWebsite(_ url: URL) {
            let request = URLRequest(url: url)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.webView.load(request)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.preferences.minimumFontSize = 10
        config.preferences.javaScriptCanOpenWindowsAutomatically = false
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        config.defaultWebpagePreferences = preferences

        let webView = WKWebView(frame: .zero, configuration: config)
        context.coordinator.webView = webView
        webView.uiDelegate = context.coordinator
        webView.navigationDelegate = context.coordinator
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 16_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.2 Mobile/15E148 Safari/604.1"

        if let url = URL(string: urlString != nil ? urlString! : viewModel.urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
}
