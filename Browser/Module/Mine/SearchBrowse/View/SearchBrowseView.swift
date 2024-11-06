//
//  SearchBrowseView.swift
//  Browser
//
//  Created by xyxy on 2024/10/8.
//

import SwiftUI

struct SearchBrowseView: View {
    enum BrowserOption: String, CaseIterable {
        case incognito = "无痕浏览"
        case favorites = "我的收藏"
        case history = "浏览历史"
        case downloads = "下载管理"
        case tabs = "标签页"
//        case extensions = "扩展程序"
//        case mediaControl = "媒体控制"
//        case textPlayback = "文本播放"

        static var sections: [[BrowserOption]] {
            return [BrowserOption.allCases]
        }
    }

    @ObservedObject var viewModel = ViewModel.shared

    var body: some View {
        OptionListView(
            sections: BrowserOption.sections,
            rightViewProvider: { option in
                switch option {
                case .incognito:
                    return AnyView(
                        Toggle("", isOn: $viewModel.openNoTrace)
                            .labelsHidden()
                            .onChange(of: viewModel.openNoTrace) { newValue in
                                viewModel.openNoTrace = newValue
                            }
                    )
                default:
                    return nil
                }
            },
            onTap: handleTap(for:)
        )
        .padding(.horizontal, 16)
    }

    private func handleTap(for item: BrowserOption) {
        switch item {
        case .favorites:
            Util.topViewController().navigationController?.pushViewController(FootprintViewController(selectedSegmentIndex: 0), animated: true)
        case .history:
            Util.topViewController().navigationController?.pushViewController(FootprintViewController(selectedSegmentIndex: 1), animated: true)
        case .tabs:
            Util.topViewController().navigationController?.pushViewController(TabsViewController(), animated: true)
        case .downloads:
            Util.topViewController().navigationController?.pushViewController(DownloadViewController(), animated: true)
        default:
            break
        }
    }
}

//#Preview {
//    SearchBrowseView()
//}
