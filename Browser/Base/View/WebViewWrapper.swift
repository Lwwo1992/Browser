//
//  WebView.swift
//  Browser
//
//  Created by xyxy on 2024/10/12.
//

import Combine
import SwiftUI
@preconcurrency import WebKit

enum WebViewAction {
    case goBack
    case goForward
    case none
}

class WebViewViewModel: ObservableObject {
    @Published var urlString: String = ""
    @Published var refresh: Bool = true
    // 控制是否保存历史记录
    @Published var shouldSaveHistory: Bool = false
    @Published var showBottomSheet: Bool = false
    @Published var action: WebViewAction = .none
    @Published var canGoBack: Bool = false
    @Published var guideBookmark = HistoryModel()
    @Published var bookmark = HistoryModel() {
        didSet {
            if !S.Config.openNoTrace {
                DBaseManager.share.insertToDb(objects: [bookmark], intoTable: S.Table.browseHistory)
            }
        }
    }

    @Published var scanCode = false

    var shouldUpdate: Bool = true
}

struct WebViewWrapper: UIViewRepresentable {
    @ObservedObject var viewModel: WebViewViewModel

    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate, UIDocumentInteractionControllerDelegate {
        var parent: WebViewWrapper
        var webView: WKWebView! {
            didSet {
                webView.addObserver(self, forKeyPath: "canGoBack", options: [.new, .old], context: nil)
                webView.addObserver(self, forKeyPath: "canGoForward", options: [.new, .old], context: nil)
            }
        }

        private var cancellables = Set<AnyCancellable>()
        private var mode = WKWebpagePreferences.ContentMode.mobile

        init(_ parent: WebViewWrapper) {
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

            parent.viewModel.$action
                .dropFirst()
                .sink { [weak self] action in
                    guard let self else { return }
                    if action == .goBack {
                        goBack()
                    }
                }
                .store(in: &cancellables)
        }

        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
            if (object as? WKWebView) == webView {
                if keyPath == "canGoBack" {
                    parent.viewModel.canGoBack = webView.canGoBack
                }
            } else {
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            }
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print(webView.url?.absoluteString ?? "")
            print("网页开始加载")
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let model = HistoryModel()
            model.title = webView.title
            model.address = parent.viewModel.urlString

            webView.evaluateJavaScript("document.querySelector('link[rel*=\"icon\"]').href") { result, error in
                if let logo = result as? String {
                    model.pageLogo = logo
                } else {
                    print("Failed to get logo: \(String(describing: error?.localizedDescription))")
                }

                self.takeSnapshot { [weak self] imagePath in
                    guard let self else { return }
                    model.imagePath = imagePath
                    parent.viewModel.bookmark = model
                }
            }
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            // 检测是否是配置文件的请求
            if url.absoluteString.hasPrefix("data:application/x-apple-aspen-config;base64,") {
                // 弹窗提示
                let alertController = UIAlertController(title: "下载配置文件", message: "此网站正尝试下载一个配置描述文件。你要允许吗？", preferredStyle: .alert)

                // 允许按钮
                let allowAction = UIAlertAction(title: "允许", style: .default) { _ in
                    self.handleBase64ConfigData(url: url) // 处理配置文件的下载和保存
                    decisionHandler(.cancel) // 取消默认加载行为
                }

                // 不允许按钮
                let denyAction = UIAlertAction(title: "不允许", style: .cancel) { _ in
                    decisionHandler(.cancel)
                }

                alertController.addAction(allowAction)
                alertController.addAction(denyAction)

                // 显示弹窗
                Util.topViewController().present(alertController, animated: true, completion: nil)

                return
            }

            if BWebViewManager.share.isDownloadLink(url: url) {
                BWebViewManager.share.handleDownload(url: url) { [self] url1, name, size in
                    if let url1 {
                        self.saveDownInfo(url: url1.absoluteString, name: name ?? "", size: size ?? 0)
                    }
                }
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("Failed to load webpage: \(error.localizedDescription)")
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

        /// 加载网站
        private func loadWebsite(_ url: URL) {
            let request = URLRequest(url: url)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.webView.load(request)
            }
        }

        /// 保存下载数据
        func saveDownInfo(url: String, name: String, size: Int64) {
            let model = DownloadModel()
            model.url = url
            model.size = size
            model.title = name
            DBaseManager.share.insertToDb(objects: [model], intoTable: S.Table.download)
            HUD.showTipMessage("下载成功")
        }

        func goBack() {
            if webView.canGoBack {
                webView.goBack()
            } else {
                Util.topViewController().navigationController?.popViewController(animated: true)
            }
        }

        // 处理 Base64 配置文件
        private func handleBase64ConfigData(url: URL) {
            // 获取 Base64 编码内容
            let base64Content = url.absoluteString.replacingOccurrences(of: "data:application/x-apple-aspen-config;base64,", with: "")

            // Base64 解码为数据
            if let data = Data(base64Encoded: base64Content) {
                let fileURL = saveToFile(data: data)

                // 使用保存的配置文件
                openMobileConfig(fileURL: fileURL)
            } else {
                print("无法解码 Base64 数据")
            }
        }

        private func saveToFile(data: Data) -> URL {
            let tempDirectory = FileManager.default.temporaryDirectory
            let fileURL = tempDirectory.appendingPathComponent("config.mobileconfig")

            do {
                try data.write(to: fileURL)
                print("配置文件已保存到: \(fileURL)")
            } catch {
                print("保存配置文件失败: \(error)")
            }
            return fileURL
        }

        private func openMobileConfig(fileURL: URL) {
            // 检查系统是否支持打开文件 URL
            if UIApplication.shared.canOpenURL(fileURL) {
                UIApplication.shared.open(fileURL, options: [:], completionHandler: { success in
                    if success {
                        print("已成功打开配置文件")
                    } else {
                        print("打开配置文件失败")
                    }
                })
            } else {
                print("无法打开配置文件：系统限制")
                if let settingsURL = URL(string: "App-prefs:root=General&path=ManagedConfigurationList") {
                    if UIApplication.shared.canOpenURL(settingsURL) {
                        UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                    }
                }

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

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if viewModel.shouldUpdate, let url = URL(string: viewModel.urlString) {
            let request = URLRequest(url: url)
            uiView.load(request)
            viewModel.shouldUpdate = false
            ViewModel.shared.updateWeb = false
        }
    }
}
