//
//  AboutView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/9.
//

import SwiftUI

struct AboutView: View {
    enum AboutOption: String, CaseIterable {
        case checkForUpdates = "检查版本更新"
        case privacyPolicy = "隐私政策"
        case termsOfService = "服务条款"

        static var sections: [[AboutOption]] {
            [
                [.checkForUpdates],
                [.privacyPolicy, .termsOfService],
            ]
        }
    }

    @State private var isOn: Bool = false

    var body: some View {
        OptionListView(
            sections: AboutOption.sections,
            onTap: handleTap(for:)
        )
        .padding(.horizontal, 16)
    }

    private func handleTap(for item: AboutOption) {
//        var vc = ViewController()
//        switch item {
//        default:
//            break
//        }
//        vc.title = item.rawValue
//        Util.topViewController().navigationController?.pushViewController(vc, animated: true)
    }
}

#Preview {
    AboutView()
}
