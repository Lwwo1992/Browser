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

    var body: some View {
        OptionListView(
            sections: GeneralOption.sections,
            additionalTextProvider: { option in
                switch option {
                case .recommendedMode:
                    return "导航"
                case .clearCache:
                    return "146.2MB"
                default:
                    return nil
                }
            },
            onTap: handleTap(for:)
        )
        .padding(.horizontal, 16)
//        ScrollView {
//            VStack(alignment: .leading, spacing: 0) {
//                ForEach(0 ..< GeneralOption.sections.count, id: \.self) { sectionIndex in
//                    VStack(alignment: .leading, spacing: 0) {
//                        ForEach(GeneralOption.sections[sectionIndex], id: \.self) { item in
//                            VStack(alignment: .leading, spacing: 0) {
//                                HStack(alignment: .center) {
//                                    Text(item.rawValue)
//                                    Spacer()
//                                    if item == .recommendedMode {
//                                        Text("导航")
//                                            .opacity(0.5)
//                                    } else if item == .clearCache {
//                                        Text("146.2MB")
//                                            .opacity(0.5)
//                                    }
//                                    Image(systemName: "chevron.right")
//                                }
//                                .font(.system(size: 14))
//                                .frame(height: 55)
//                                .padding(.horizontal, 16)
//                                .background(Color.white)
//                                .onTapGesture {
//                                    handleTap(for: item)
//                                }
//
//                                if item != GeneralOption.sections[sectionIndex].last {
//                                    Divider()
//                                        .padding(.leading, 16)
//                                }
//                            }
//                        }
//                    }
//                    .background(Color.white)
//                    .cornerRadius(10)
//                    .padding(.vertical)
//                }
//            }
//        }
//        .padding(.horizontal, 16)
//        .background(Color(hex: 0xF8F5F5))
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
