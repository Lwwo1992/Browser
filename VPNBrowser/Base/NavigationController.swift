//
//  NavigationController.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/8.
//

import UIKit

class NavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarAppearance()
        clearStyle()
        view.backgroundColor = .white
        delegate = self
        interactivePopGestureRecognizer?.delegate = self
    }

    private func setupNavigationBarAppearance() {
        let titleTextAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .medium),
            .foregroundColor: UIColor(hex: 0x000000),
        ]
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.titleTextAttributes = titleTextAttributes
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
        }
        navigationBar.shadowImage = UIImage()
    }

    private func applyNavigationBarStyle(color: UIColor, shadowColor: UIColor? = nil, isTranslucent: Bool = false) {
        navigationBar.isTranslucent = isTranslucent
        navigationBar.barTintColor = UIColor.white
        navigationBar.tintColor = UIColor(hex: 0x000000)

        if #available(iOS 13.0, *) {
            let appearance = navigationBar.standardAppearance
            appearance.backgroundColor = color
            appearance.shadowImage = nil
            appearance.shadowColor = shadowColor
            appearance.backgroundImage = UIImage(with: color)
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
        } else {
            navigationBar.setBackgroundImage(UIImage(with: color), for: .default)
            navigationBar.backgroundColor = color
        }
    }

    @objc func defaultStyle(_ color: UIColor = .init(hex: 0x3C197A), shadowColor: UIColor? = nil) {
        applyNavigationBarStyle(color: color, shadowColor: shadowColor)
    }

    @objc func clearStyle() {
        applyNavigationBarStyle(color: .clear, isTranslucent: true)
    }

    override var childForStatusBarStyle: UIViewController? {
        self.topViewController
    }

    override func pushViewController(_ viewController: UIViewController, animated _: Bool) {
        if children.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        } else {
            viewController.hidesBottomBarWhenPushed = false
        }
        super.pushViewController(viewController, animated: true)
    }

    @objc func changeNavigationBarAlpha(_ alphaOffset: CGFloat, color: UIColor) {
        let alpha = max(alphaOffset, 0) / 80
        if #available(iOS 13.0, *) {
            let appearance = navigationBar.standardAppearance
            appearance.backgroundImage = UIImage(with: color.withAlphaComponent(alpha))
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
        } else {
            navigationBar.setBackgroundImage(UIImage(with: color.withAlphaComponent(alpha)), for: .default)
        }
    }
}

extension NavigationController: UINavigationControllerDelegate {
    func navigationController(_: UINavigationController,
                              willShow viewController: UIViewController,
                              animated _: Bool) {
        if children.count > 1 {
            let image = UIImage(resource: .backIndicator).withRenderingMode(.alwaysOriginal)
            let item = UIBarButtonItem(image: image,
                                       style: .plain,
                                       target: self,
                                       action: #selector(UINavigationController.popViewController(animated:)))
            viewController.navigationItem.leftBarButtonItem = item
        }
    }
}

extension NavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == interactivePopGestureRecognizer {
            if viewControllers.count < 2 || visibleViewController == viewControllers.first {
                return false
            }
        }
        return true
    }
}

public extension UIImage {
    convenience init?(with color: UIColor,
                      size: CGSize = CGSize(width: 1, height: 1),
                      scale: CGFloat = 1.0) {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = scale
        let rect = CGRect(origin: .zero, size: size)
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let image = renderer.image { ctx in
            color.setFill()
            ctx.fill(rect)
        }

        guard let cgImage = image.cgImage else { return nil }
        self.init(cgImage: cgImage, scale: scale, orientation: .up)
    }
}
