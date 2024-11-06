//
//  DocumentInteractionController.swift
//  Browser
//
//  Created by xyxy on 2024/10/16.
//

import SwiftUI
import UIKit

struct DocumentInteractionController: UIViewControllerRepresentable {
    var fileUrl: URL

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // 创建 UIDocumentInteractionController 实例
        let documentInteractionController = UIDocumentInteractionController(url: fileUrl)
        documentInteractionController.delegate = context.coordinator

        // 展示文件预览
        documentInteractionController.presentPreview(animated: true)
    }

    // 创建协调器
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    // 协调器类，用于处理委托
    class Coordinator: NSObject, UIDocumentInteractionControllerDelegate {
        var parent: DocumentInteractionController

        init(_ parent: DocumentInteractionController) {
            self.parent = parent
        }

        // MARK: - UIDocumentInteractionControllerDelegate

        func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
            return UIApplication.shared.windows.first!.rootViewController!
        }
    }
}
