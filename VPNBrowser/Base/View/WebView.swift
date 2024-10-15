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
    @Published var showBottomSheet: Bool = false
}

struct WebView: UIViewRepresentable {
    var urlString: String? = nil
    @ObservedObject var viewModel = WebViewViewModel()
    var onSaveInfo: ((HistoryModel) -> Void)? = nil // 闭包，用于保存历史记录

    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate {
        var parent: WebView
        var webView: WKWebView!

        private var cancellables = Set<AnyCancellable>()
        private var mode = WKWebpagePreferences.ContentMode.mobile

        init(_ parent: WebView) {
            self.parent = parent
            super.init()

            // 监听刷新操作
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

        // 页面加载完成时保存书签
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            withAnimation {
                parent.viewModel.refresh = false
            }

            // 创建历史记录模型
            let model = HistoryModel()
            model.title = webView.title
            model.path = parent.viewModel.urlString

            // 获取页面 logo（书签图标）
            webView.evaluateJavaScript("document.querySelector('link[rel*=\"icon\"]').href") { result, error in
                if let logo = result as? String {
                    model.pageLogo = logo
                } else {
                    print("Failed to get logo: \(String(describing: error?.localizedDescription))")
                }

                self.takeSnapshot { imagePath in
                    model.imagePath = imagePath

                    self.parent.onSaveInfo?(model)
                }
            }
        }

        // 加载失败
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("Failed to load webpage: \(error.localizedDescription)")
            withAnimation {
                parent.viewModel.refresh = false
            }
        }

        // 控制加载策略和内容模式
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
            preferences.preferredContentMode = mode
            decisionHandler(.allow, preferences)
        }

        private func takeSnapshot(completion: @escaping (String?) -> Void) {
            let config = WKSnapshotConfiguration()
            config.rect = webView.bounds

            webView.takeSnapshot(with: config) { image, error in
                if let error = error {
                    print("Failed to take snapshot: \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                if let image = image {
                    let filePath = self.saveImageToCustomDirectory(image: image)
                    completion(filePath)
                } else {
                    completion(nil)
                }
            }
        }

        private func saveImageToCustomDirectory(image: UIImage) -> String? {
            let folderURL = S.Files.imageURL

            // 检查文件夹是否存在，不存在则创建
            if !FileManager.default.fileExists(atPath: folderURL.path) {
                Util.createFolderIfNotExists(folderURL)
            }

            // 生成唯一的图片文件名
            let fileName = UUID().uuidString + ".png"
            let fileURL = folderURL.appendingPathComponent(fileName)

            if let data = image.pngData() {
                do {
                    // 写入文件
                    try data.write(to: fileURL)
                    return fileName
                } catch {
                    print("Failed to save image: \(error)")
                    return nil
                }
            }
            return nil
        }

        // 加载网站
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

        if let url = URL(string: urlString ?? viewModel.urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
}
