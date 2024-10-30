//
//  MineBottomView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/8.
//

import SwiftUI

struct MineBottomView: View {
    enum MineBottomOption: String, CaseIterable {
        case accountSecurity = "账户安全"
        case searchBrowse = "搜索浏览"
        case incognito = "无痕浏览"
        case cloudSync = "云同步"
        case general = "通用"
        case userGuide = "使用指南"
        case customerService = "客服咨询"
        case about = "关于"

        static var sections: [[MineBottomOption]] {
            [
                [.accountSecurity, .searchBrowse, .incognito],
                [.cloudSync],
                [.general, .userGuide, /* .customerService, */ .about],
            ]
        }
    }

    @ObservedObject var viewModel = ViewModel.shared

    var body: some View {
        OptionListView(
            sections: MineBottomOption.sections,
            rightViewProvider: { option in
                if option == .incognito {
                    return AnyView(
                        Toggle("", isOn: $viewModel.openNoTrace)
                            .labelsHidden()
                            .onChange(of: viewModel.openNoTrace) { newValue in
                                viewModel.openNoTrace = newValue
                            }
                    )
                }
                return nil
            },
            onTap: handleTap(for:)
        )
    }

    private func handleTap(for item: MineBottomOption) {
        let viewControllerMap: [MineBottomOption: (UIViewController.Type, String?)] = [
            .accountSecurity: (LoginManager.shared.info.userType == .visitor || LoginManager.shared.info.token.isEmpty) ? (LoginViewController.self, nil) : (SecurityViewController.self, item.rawValue),
            .searchBrowse: (SearchBrowseViewController.self, item.rawValue),
            .cloudSync: (CloudSyncViewController.self, item.rawValue),
            .general: (GeneralViewController.self, item.rawValue),
            .about: (AboutViewController.self, item.rawValue),
            .userGuide: (UserGuideViewController.self, item.rawValue),
        ]

        guard item != .incognito, let (vcType, title) = viewControllerMap[item] else { return }

        let vc = vcType.init()
        vc.title = title

        Util.topViewController().navigationController?.pushViewController(vc, animated: true)
    }
}

#Preview {
    MineBottomView()
}
