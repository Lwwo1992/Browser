import Combine
import SwiftUI
@preconcurrency import WebKit

@dynamicMemberLookup
public class WebViewStore: NSObject, ObservableObject {
    @Published public var webView: WKWebView {
        didSet {
            setupObservers()
            webView.navigationDelegate = self
        }
    }

    @Published var tabManager = WebViewTabManager()

    private var model: HistoryModel?

    public init(webView: WKWebView = WKWebView()) {
        self.webView = webView
        super.init()
        self.webView.navigationDelegate = self
        setupObservers()
        loadTabsFromDatabase()
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

    private var observers: [NSKeyValueObservation] = []

    public subscript<T>(dynamicMember keyPath: KeyPath<WKWebView, T>) -> T {
        webView[keyPath: keyPath]
    }
}

extension WebViewStore {
    // 从数据库加载标签页
    private func loadTabsFromDatabase() {
        if let savedTabs = DBaseManager.share.qureyFromDb(fromTable: S.Table.bookmark, cls: HistoryModel.self) {
            for record in savedTabs {
                let webView = WKWebView()
                if let address = record.address, let url = URL(string: address) {
                    webView.load(URLRequest(url: url))
                    let tab = WebViewTab(webView: webView, url: url, title: record.title)
                    tab.lastAccessed = record.lastAccessed ?? Date()
                    tab.imagePath = record.imagePath
                    tabManager.tabs.append(tab)
                }
            }
        }
    }

    // 切换到指定的标签页
    public func switchToTab(at index: Int) {
        tabManager.selectTab(at: index)
    }

    // 创建新的标签页
    public func createNewTab() {
        if let model {
            tabManager.addTab(url: webView.url, title: webView.title)
            DBaseManager.share.insertToDb(objects: [model], intoTable: S.Table.bookmark)
        }
    }

    // 刷新选中的标签
    public func refreshSelectedTab() {
        guard let selectedTab = tabManager.selectedTab else { return }
        selectedTab.webView.reload()
        selectedTab.updateCacheTime() // 更新缓存时间
    }

    // 获取选中标签的 WebView
    public func getSelectedWebView() -> WKWebView? {
        return tabManager.selectedTab?.webView
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

        // 保存 HTML 内容
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { [weak self] html, error in
            guard let self = self, let htmlString = html as? String, error == nil else { return }
            
        }

        // 保存滚动位置
        webView.evaluateJavaScript("window.scrollY") { [weak self] scrollY, error in
            guard let self = self, let scrollPosition = scrollY as? CGFloat, error == nil else { return }

        }

        self.model = model

        if !S.Config.openNoTrace {
            DBaseManager.share.insertToDb(objects: [model], intoTable: S.Table.browseHistory)
        }
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }

    @available(iOS 14.5, *)
    public func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
        download.delegate = self
    }

    @available(iOS 14.5, *)
    public func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String, completionHandler: @escaping (URL?) -> Void) {
        let downloadsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let destinationURL = downloadsDirectory.appendingPathComponent(suggestedFilename)
        completionHandler(destinationURL)
    }

    @available(iOS 14.5, *)
    public func downloadDidFinish(_ download: WKDownload) {
        print("下载完成: \(download)")
    }

    @available(iOS 14.5, *)
    public func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
        print("下载失败: \(error.localizedDescription)")
    }
}

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
