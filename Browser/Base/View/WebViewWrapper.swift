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

            var decisionMade = false

            // 确保 decisionHandler 只调用一次
            func safeDecisionHandler(_ policy: WKNavigationActionPolicy) {
                if !decisionMade {
                    decisionMade = true
                    DispatchQueue.main.async {
                        decisionHandler(policy)
                    }
                }
            }

            // 1. 检查是否是配置文件请求
            if url.absoluteString.hasPrefix("data:application/x-apple-aspen-config;base64,") {
                let alertController = UIAlertController(title: "下载配置文件", message: "此网站正尝试下载一个配置描述文件。你要允许吗？", preferredStyle: .alert)

                let allowAction = UIAlertAction(title: "允许", style: .default) { _ in
                    self.handleBase64ConfigData(url: url) // 处理配置文件的下载和保存
                    safeDecisionHandler(.cancel) // 取消默认加载行为
                }

                let denyAction = UIAlertAction(title: "不允许", style: .cancel) { _ in
                    safeDecisionHandler(.cancel) // 取消加载
                }

                alertController.addAction(allowAction)
                alertController.addAction(denyAction)

                // 显示弹窗
                Util.topViewController().present(alertController, animated: true, completion: nil)
                return
            }

            // 2. 检查地理位置（是否是国外网站）
            handleRequestWithGeoLocationCheck(url: url) { [weak self] isForeign in
                guard let self else { return }
                if isForeign {
                    safeDecisionHandler(.cancel)

                    // 使用自定义方法发送请求
                    if navigationAction.request.httpMethod == "GET" {
                        self.handleCustomGetRequest(url: url)
                    } else if navigationAction.request.httpMethod == "POST" {
                        self.handleCustomPostRequest(url: url, request: navigationAction.request)
                    }
                } else {
                    safeDecisionHandler(.allow) // 允许加载
                }
            }

            // 3. 检测是否是下载链接
            if BWebViewManager.share.isDownloadLink(url: url) {
                BWebViewManager.share.handleDownload(url: url) { [self] url1, name, size in
                    if let url1 {
                        self.saveDownInfo(url: url1.absoluteString, name: name ?? "", size: size ?? 0)
                    }
                }
                safeDecisionHandler(.cancel) // 下载链接处理后不继续执行
                return // 下载链接处理后不继续执行
            }

            // 对于所有其他请求，允许加载
            safeDecisionHandler(.allow)
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

        private func shouldHandleRequestWithCustomMethod(url: URL) -> Bool {
            guard let host = url.host else { return false }

            // 常见的国外顶级域名（TLD）列表
            let foreignTLDs = ["com", "org", "net", "gov", "io", "co", "tv", "me", "us"]

            // 获取 URL 的最后一个域名后缀（即 TLD）
            let domainComponents = host.split(separator: ".")
            if let lastComponent = domainComponents.last {
                // 检查域名后缀是否在国外域名列表中
                if foreignTLDs.contains(String(lastComponent)) {
                    return true // 认为是国外网站，需要翻墙
                }
            }

            return false // 如果是国内的域名或其他，则不拦截
        }

        func handleRequestWithGeoLocationCheck(url: URL, completion: @escaping (Bool) -> Void) {
            // 使用IP地理位置API检查IP是否来自国外
            let request = HttpProxyRequest.manager()!
            request.sendGet(withURL: "http://ip-api.com/json/\(url.host ?? "")", parameters: [:]) { res in
                if let data = res?.data {
                    // 解析IP返回的地理位置数据
                    if let json = self.mapJSON(data: data) as? [String: Any], let country = json["country"] as? String {
                        if country != "China" {
                            // 如果不是来自中国，认为是国外网站
                            print("需要翻墙的网站：\(url.host ?? "")")
                            completion(true) // 表示是国外网站
                        } else {
                            // 如果是中国的IP地址，正常加载
                            print("国内网站：\(url.host ?? "")")
                            completion(false) // 表示是国内网站
                        }
                    }
                } else {
                    completion(false) // 无法获取地理位置时认为是国内网站
                }
            }
        }

        // 自定义 GET 请求方法
        private func handleCustomGetRequest(url: URL) {
            let request = HttpProxyRequest.manager()!
            request.sendGet(withURL: url.absoluteString, parameters: [:]) { res in
                if let data = res?.data, let htmlString = self.parseResponseToHTML(data: data) {
                    // 将 HTML 字符串加载到 WebView 中
                    DispatchQueue.main.async {
                        self.webView.loadHTMLString(htmlString, baseURL: url)
                    }
                } else {
                    print("GET请求错误：\(res?.message ?? "")")
                }
            }
        }

        // 自定义 POST 请求方法
        private func handleCustomPostRequest(url: URL, request: URLRequest) {
            var parameters: [String: Any] = [:]
            if let body = request.httpBody,
               let json = try? JSONSerialization.jsonObject(with: body, options: []) as? [String: Any] {
                parameters = json
            }

            let customRequest = HttpProxyRequest.manager()!
            customRequest.sendPost(withURL: url.absoluteString, parameters: parameters) { [weak self] res in
                guard let self else { return }
                if let data = res?.data, let htmlString = self.parseResponseToHTML(data: data) {
                    // 将 HTML 字符串加载到 WebView 中
                    DispatchQueue.main.async {
                        self.webView.loadHTMLString(htmlString, baseURL: url)
                    }
                } else {
                    print("POST请求错误：\(res?.message ?? "")")
                }
            }
        }

        // 将返回的数据转换为 HTML 字符串的方法
        private func parseResponseToHTML(data: Data) -> String? {
            // 尝试将 data 转换为 JSON 对象
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
               let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                // 创建简单的 HTML 模板
                return """
                <html>
                <head>
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <style>
                        body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; padding: 16px; }
                        pre { white-space: pre-wrap; word-wrap: break-word; }
                    </style>
                </head>
                <body>
                    <h1>请求结果</h1>
                    <pre>\(jsonString)</pre>
                </body>
                </html>
                """
            }
            return nil
        }

        func mapJSON(data: Data) -> Any? {
            do {
                // Try to parse the data as JSON
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                return json
            } catch {
                print("Error parsing JSON: \(error)")
                return nil
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
