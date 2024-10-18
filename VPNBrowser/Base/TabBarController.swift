//
//  TabBarController.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/8.
//

import UIKit

class TabBarController: UITabBarController {
    enum ContentStyle: CaseIterable {
        case home, browser, mine

        var tabBarTitle: String {
            switch self {
            case .home:
                return "首页"
            case .browser:
                return "浏览器"
            case .mine:
                return "我的"
            }
        }

        var defaultIcon: UIImage {
            switch self {
            case .home: UIImage(resource: .tabbarHome)
            case .browser: UIImage(resource: .tabbarBrowser)
            case .mine: UIImage(resource: .tabbarMine)
            }
        }

        var selectedIcon: UIImage {
            switch self {
            case .home: UIImage(resource: .tabbarHomeSelected)
            case .browser: UIImage(resource: .tabbarBrowserSelected)
            case .mine: UIImage(resource: .tabbarMineSelected)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()

        selectedIndex = ContentStyle.allCases.firstIndex(of: .browser) ?? 1
    }

    private func initUI() {
        tabBar.barStyle = .black
        tabBar.isTranslucent = false
        tabBar.barTintColor = UIColor.black
        tabBar.tintColor = UIColor.black
        tabBar.layer.backgroundColor = UIColor(hex: 0xFFFFFF).cgColor

        configureViewControllers()
    }

    private func configureViewControllers() {
        var viewControllers: [UIViewController] = []

        for item in ContentStyle.allCases {
            let navigationController: NavigationController
            var root: ViewController

            switch item {
            case .home:
                root = HomeViewController()
            case .browser:
                root = BrowserViewController()
            case .mine:
                root = MineViewController()
            }

            navigationController = NavigationController(rootViewController: root)
            navigationController.tabBarItem = UITabBarItem(title: item.tabBarTitle,
                                                           image: item.defaultIcon.withRenderingMode(.alwaysOriginal),
                                                           selectedImage: item.selectedIcon.withRenderingMode(.alwaysOriginal))
            viewControllers.append(navigationController)
        }

        self.viewControllers = viewControllers
    }
}
