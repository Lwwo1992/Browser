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
        var vc = ViewController()
        switch item {
        case .accountSecurity:
            if S.Config.isLogin {
                vc = SecurityViewController()
            } else {
                vc = LoginViewController()
            }
        case .searchBrowse:
            vc = SearchBrowseViewController()
        case .cloudSync:
            vc = CloudSyncViewController()
        case .general:
            vc = GeneralViewController()
        case .about:
            vc = AboutViewController()
        case .userGuide:
            vc = UserGuideViewController()
        default:
            break
        }

        if item != .incognito {
            vc.title = item.rawValue
            Util.topViewController().navigationController?.pushViewController(vc, animated: true)
        }
    }
}

#Preview {
    MineBottomView()
}
