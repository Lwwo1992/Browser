//
//  GeneralView.swift
//  Browser
//
//  Created by xyxy on 2024/10/9.
//

import SwiftUI

struct GeneralView: View {
    enum GeneralOption: String, CaseIterable {
        case recommendedMode = "推荐模式"
        case defaultDownloadDir = "默认下载目录"
        case clearCache = "缓存"
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

    @State private var showingDeleteAlert = false

    @State private var fileSize = ""

    var body: some View {
        OptionListView(
            sections: GeneralOption.sections,
            additionalTextProvider: { option in
                switch option {
                case .recommendedMode:
                    return viewModel.selectedModel.rawValue
                case .clearCache:
                    return fileSize
                case .defaultDownloadDir:
                    let downloadsURL = URL(fileURLWithPath: Util.documentsPath).appendingPathComponent("Downloads")
                    let documentsURL = URL(fileURLWithPath: Util.documentsPath)
                    let shortString = downloadsURL.relativePath.replacingOccurrences(of: documentsURL.path, with: "")
                    return shortString
                default:
                    return nil
                }
            },
            rightViewProvider: { option in
                switch option {
                case .defaultDownloadDir:
                    return AnyView(EmptyView())
                default:
                    return nil
                }
            },
            onTap: handleTap(for:)
        )
        .padding(.horizontal, 16)
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("删除记录"),
                message: Text("您确定要删除此记录吗？"),
                primaryButton: .destructive(Text("删除")) {
                    DBaseManager.share.deleteFromDb(fromTable: S.Table.browseHistory)
                    DBaseManager.share.deleteFromDb(fromTable: S.Table.searchHistory)
                    fileSize = Util.formatFileSize(Util.getFileSize(dbPath: DataBasePath().dbPath) ?? 0)
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            fileSize = Util.formatFileSize(Util.getFileSize(dbPath: DataBasePath().dbPath) ?? 0)
        }
    }

    private func handleTap(for item: GeneralOption) {
        var vc = ViewController()
        switch item {
        case .recommendedMode:
            vc = RecommendedModeViewController()
            vc.title = item.rawValue
            Util.topViewController().navigationController?.pushViewController(vc, animated: true)
        case .clearCache:
            showingDeleteAlert.toggle()
        default:
            break
        }
    }
}
