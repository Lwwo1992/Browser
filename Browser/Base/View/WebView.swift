import Combine
import SwiftUI
@preconcurrency import WebKit

@dynamicMemberLookup
class WebViewStore: NSObject, ObservableObject {
    @Published public var webView: WKWebView {
        didSet {
            setupObservers()
            webView.navigationDelegate = self
        }
    }

    private var observers: [NSKeyValueObservation] = []

    private var footprintModel: HistoryModel?

    public init(webView: WKWebView = WKWebView()) {
        self.webView = webView
        super.init()
        self.webView.navigationDelegate = self
        setupObservers()
    }
}

extension WebViewStore {
    func addTab() {
        if let footprintModel {
            DBaseManager.share.insertToDb(objects: [footprintModel], intoTable: S.Table.bookmark)
        }
    }

    public subscript<T>(dynamicMember keyPath: KeyPath<WKWebView, T>) -> T {
        webView[keyPath: keyPath]
    }

    private func setupObservers() {
        func subscriber<Value>(for keyPath: KeyPath<WKWebView, Value>) -> NSKeyValueObservation {
            return webView.observe(keyPath, options: [.prior]) { _, change in
                if change.isPrior {
                    self.objectWillChange.send()
                }
            }
        }
        // Setup observers for all KVO compliant properties
        observers = [
            subscriber(for: \.title),
            subscriber(for: \.url),
            subscriber(for: \.isLoading),
            subscriber(for: \.estimatedProgress),
            subscriber(for: \.hasOnlySecureContent),
            subscriber(for: \.serverTrust),
            subscriber(for: \.canGoBack),
            subscriber(for: \.canGoForward),
        ]
        if #available(iOS 15.0, macOS 12.0, *) {
            observers += [
                subscriber(for: \.themeColor),
                subscriber(for: \.underPageBackgroundColor),
                subscriber(for: \.microphoneCaptureState),
                subscriber(for: \.cameraCaptureState),
            ]
        }
        #if swift(>=5.7)
            if #available(iOS 16.0, macOS 13.0, *) {
                observers.append(subscriber(for: \.fullscreenState))
            }
        #else
            if #available(iOS 15.0, macOS 12.0, *) {
                observers.append(subscriber(for: \.fullscreenState))
            }
        #endif
    }
}

extension WebViewStore: WKNavigationDelegate, WKDownloadDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let model = HistoryModel()
        model.title = webView.title
        model.address = webView.url?.absoluteString

        webView.evaluateJavaScript("document.querySelector('link[rel*=\"icon\"]').href") { result, error in
            if let logo = result as? String {
                model.pageLogo = logo
            } else {
                print("Failed to get logo: \(String(describing: error?.localizedDescription))")
            }

            self.takeSnapshot { imagePath in
                model.imagePath = imagePath
            }
        }

        if !S.Config.openNoTrace {
            DBaseManager.share.insertToDb(objects: [model], intoTable: S.Table.browseHistory)
        }

        self.footprintModel = model
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

        isForeignURL(url) { [weak self] isForeign in
            guard let self else { return }
            if isForeign {
                decisionHandler(.cancel)
                if navigationAction.request.httpMethod == "GET" {
                    self.handleCustomGetRequest(url: url)
                } else if navigationAction.request.httpMethod == "POST" {
                    self.handleCustomPostRequest(url: url, request: navigationAction.request)
                }
            } else if BWebViewManager.share.isDownloadLink(url: url) {
                decisionHandler(.cancel)
                BWebViewManager.share.handleDownload(url: url) { [self] url1, name, size in
                    if let url1 {
                        self.saveDownInfo(url: url1.absoluteString, name: name ?? "", size: size ?? 0)
                    }
                }
            } else {
                decisionHandler(.allow)
            }
        }
    }

    func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
        download.delegate = self
    }

    func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String, completionHandler: @escaping (URL?) -> Void) {
        let downloadsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let destinationURL = downloadsDirectory.appendingPathComponent(suggestedFilename)
        completionHandler(destinationURL)
    }

    func downloadDidFinish(_ download: WKDownload) {
        print("下载完成: \(download)")
    }

    func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
        print("下载失败: \(error.localizedDescription)")
    }
}

/// 保存浏览器信息
extension WebViewStore {
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
        // 生成唯一的图片文件名
        let fileName = UUID().uuidString + ".png"
        let fileURL = S.Files.imageURL.appendingPathComponent(fileName)

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
}

extension WebViewStore {
    // 判断是否为下载链接
    func isDownloadLink(url: URL) -> Bool {
        let fileExtensions = ["pdf", "zip", "mp3", "jpg", "png"] // 常见的下载文件扩展名
        return fileExtensions.contains(url.pathExtension.lowercased())
    }

    // 处理下载操作（使用 URLSession）
    func handleDownload(url: URL) {
        let downloadTask = URLSession.shared.downloadTask(with: url) { location, _, error in
            if let location = location {
                let destinationURL = self.getDownloadDestinationURL(for: url)
                do {
                    try FileManager.default.moveItem(at: location, to: destinationURL)
                    print("下载完成: \(destinationURL.path)")
                } catch {
                    print("下载失败: \(error.localizedDescription)")
                }
            }
        }
        downloadTask.resume()
    }

    // 获取下载文件保存路径
    func getDownloadDestinationURL(for url: URL) -> URL {
        let downloadsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        return downloadsDirectory.appendingPathComponent(url.lastPathComponent)
    }
}

extension WebViewStore {
    /// 保存下载数据
    func saveDownInfo(url: String, name: String, size: Int64) {
        let model = DownloadModel()
        model.url = url
        model.size = size
        model.title = name
        DBaseManager.share.insertToDb(objects: [model], intoTable: S.Table.download)
        HUD.showTipMessage("下载成功")
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

extension WebViewStore {
    /// 判断是否为国外的URL
    private func isForeignURL(_ url: URL, completion: @escaping (Bool) -> Void) {
        guard let host = url.host else {
            completion(false)
            return
        }

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }

            // 使用 gethostbyname 解析域名到 IP 地址
            let hostEntry = gethostbyname(host)
            guard let hostEntry = hostEntry, hostEntry.pointee.h_length > 0 else {
                completion(false)
                return
            }

            // 获取第一个 IP 地址
            if let addrList = hostEntry.pointee.h_addr_list, let addr = addrList[0] {
                // 将字节拷贝到 in_addr 结构体
                var inAddr = in_addr()
                memcpy(&inAddr, addr, MemoryLayout<in_addr>.size)

                // 将 IP 地址转换为字符串
                if let ipAddressCString = inet_ntoa(inAddr) {
                    let ipAddress = String(cString: ipAddressCString)

                    // 调用 fetchCountryForIP 方法查询国家信息
                    self.fetchCountryForIP(ip: ipAddress) { country in
                        // 假设 country == "CN" 为国内，其他为国外
                        let isForeign = country != "CN"
                        completion(isForeign)
                    }
                    return
                }
            }

            completion(false) // 解析失败，返回 false
        }
    }

    // 示例：使用在线 API 查询 IP 地址对应国家
    private func fetchCountryForIP(ip: String, completion: @escaping (String) -> Void) {
        let urlString = "https://ipinfo.io/\(ip)/country" // 示例 API
        guard let url = URL(string: urlString) else {
            completion("")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil, let country = String(data: data, encoding: .utf8) else {
                completion("")
                return
            }
            completion(country.trimmingCharacters(in: .whitespacesAndNewlines))
        }.resume()
    }

    // 自定义 GET 请求方法
    private func handleCustomGetRequest(url: URL) {
        let request = HttpProxyRequest.manager()!
        request.sendGet(withURL: url.absoluteString, parameters: [:]) { res in

            if let res, let data = res.data, let htmlString = String(data: data, encoding: .isoLatin1) {
                // 调试输出响应状态码
//                print("code: \(res.code)")
//                print("headerData: \(String(describing: String(data: headerData, encoding: .utf8)))")

                DispatchQueue.main.async {
                    self.webView.loadHTMLString(htmlString, baseURL: url)
                }
            } else {
                print("GET 请求错误：\(res?.message ?? "未知错误")")
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
            if let data = res?.data, let htmlString = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.webView.loadHTMLString(htmlString, baseURL: url)
                }
            } else {
                print("POST请求错误：\(res?.message ?? "")")
            }
        }
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

#if os(iOS)
    /// A container for using a WKWebView in SwiftUI
    public struct WebView: View, UIViewRepresentable {
        /// The WKWebView to display
        public let webView: WKWebView

        public init(webView: WKWebView) {
            self.webView = webView
        }

        public func makeUIView(context: UIViewRepresentableContext<WebView>) -> WKWebView {
            webView
        }

        public func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<WebView>) {
        }
    }
#endif

#if os(macOS)
    /// A container for using a WKWebView in SwiftUI
    public struct WebView: View, NSViewRepresentable {
        /// The WKWebView to display
        public let webView: WKWebView

        public init(webView: WKWebView) {
            self.webView = webView
        }

        public func makeNSView(context: NSViewRepresentableContext<WebView>) -> WKWebView {
            webView
        }

        public func updateNSView(_ uiView: WKWebView, context: NSViewRepresentableContext<WebView>) {
        }
    }
#endif
