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
                [.general, .userGuide, .customerService, .about],
            ]
        }
    }

    @State private var isOn: Bool = false

    var body: some View {
        OptionListView(
            sections: MineBottomOption.sections,
            rightViewProvider: { option in
                if option == .incognito {
                    return AnyView(
                        Toggle("", isOn: $isOn)
                            .labelsHidden()
                    )
                }
                return nil
            },
            onTap: handleTap(for:)
        )
//        VStack(alignment: .leading, spacing: 0) {
//            ForEach(0 ..< MineBottomOption.sections.count, id: \.self) { sectionIndex in
//                VStack(alignment: .leading) {
//                    ForEach(MineBottomOption.sections[sectionIndex], id: \.self) { item in
//                        VStack(alignment: .leading, spacing: 0) {
//                            HStack(alignment: .center) {
//                                if item == .incognito {
//                                    Toggle(item.rawValue, isOn: $isOn)
//                                        .frame(height: 20)
//                                } else {
//                                    Text(item.rawValue)
//                                    Spacer()
//                                    Image(systemName: "chevron.right")
//                                }
//                            }
//                            .font(.system(size: 14))
//                            .frame(height: 55)
//                            .padding(.horizontal, 16)
//                            .background(Color.white)
//                            .onTapGesture {
//                                handleTap(for: item)
//                            }
//
//                            if item != MineBottomOption.sections[sectionIndex].last {
//                                Divider()
//                                    .padding(.leading, 16)
//                            }
//                        }
//                    }
//                }
//                .background(Color.white)
//                .cornerRadius(10)
//                .padding(.vertical)
//            }
//        }
    }

    private func handleTap(for item: MineBottomOption) {
        var vc = ViewController()
        switch item {
        case .accountSecurity:
            vc = SecurityViewController()
        case .searchBrowse:
            vc = SearchBrowseViewController()
        case .cloudSync:
            vc = CloudSyncViewController()
        case .general:
            vc = GeneralViewController()
        case .about:
            vc = AboutViewController()
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
