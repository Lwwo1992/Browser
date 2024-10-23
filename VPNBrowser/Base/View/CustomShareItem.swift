//
//  CustomShareItem.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/22.
//

import UIKit
import LinkPresentation

class CustomShareItem: NSObject, UIActivityItemSource {
    var shareURL: URL
    var shareText: String
    var shareImage: UIImage

    init(shareURL: URL, shareText: String, shareImage: UIImage) {
        self.shareURL = shareURL
        self.shareText = shareText
        self.shareImage = shareImage
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return nil
    }

    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metaData = LPLinkMetadata()
        metaData.originalURL = shareURL
        metaData.url = metaData.originalURL
        metaData.title = shareText
        metaData.imageProvider = NSItemProvider(object: shareImage)
        return metaData
    }
}
