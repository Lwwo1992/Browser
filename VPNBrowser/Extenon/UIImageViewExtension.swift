//
//  UIImageViewExtension.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/12.
//

import Kingfisher
import UIKit

extension UIImageView {
    func setImage(with url: URL?, placeholder: String? = nil) {
        let placeholderImage = placeholder != nil ? UIImage(named: placeholder!) : nil

        kf.setImage(
            with: url,
            placeholder: placeholderImage
        )
    }
}

struct UIImageViewRepresentable: UIViewRepresentable {
    var url: URL?
    var placeholder: String?

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        uiView.setImage(with: url, placeholder: placeholder)
    }
}
