//
//  GeneralView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/9.
//

import SwiftUI

struct GeneralView: View {
    enum GeneralOption: String, CaseIterable {
        case recommendedMode = "推荐模式"
        case defaultDownloadDir = "默认下载目录"
        case clearCache = "清理缓存"
        case darkMode = "暗夜模式"
        case fontSize = "字体大小"
        case toolbar = "工具栏"

        static var sections: [[GeneralOption]] {
            [
                [.recommendedMode],
                [.defaultDownloadDir, .clearCache],
//                [.darkMode, .fontSize, .toolbar],
            ]
        }
    }

    @State private var isOn: Bool = false

    @ObservedObject var viewModel = ViewModel.shared

    var body: some View {
        OptionListView(
            sections: GeneralOption.sections,
            additionalTextProvider: { option in
                switch option {
                case .recommendedMode:
                    return viewModel.selectedModel.rawValue
                case .clearCache:
                    return ""
                default:
                    return nil
                }
            },
            onTap: handleTap(for:)
        )
        .padding(.horizontal, 16)
    }

    private func handleTap(for item: GeneralOption) {
        var vc = ViewController()
        switch item {
        case .recommendedMode:
            vc = RecommendedModeViewController()
        default:
            break
        }
        vc.title = item.rawValue
        Util.topViewController().navigationController?.pushViewController(vc, animated: true)
    }
}

#Preview {
    GeneralView()
}
