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

    public init(webView: WKWebView = WKWebView()) {
        self.webView = webView
        super.init()
        self.webView.navigationDelegate = self
        setupObservers()
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

extension WebViewStore: WKNavigationDelegate, WKDownloadDelegate {
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
