//
//  OptionListView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/9.
//

import SwiftUI

struct OptionListView<Option: RawRepresentable & CaseIterable & Hashable>: View where Option.RawValue == String {
    let sections: [[Option]]
    let onTap: (Option) -> Void
    let additionalTextProvider: ((Option) -> String?)?
    let rightViewProvider: ((Option) -> AnyView?)?
    let heightProvider: ((Option) -> CGFloat?)?

    init(
        sections: [[Option]],
        additionalTextProvider: ((Option) -> String?)? = nil,
        rightViewProvider: ((Option) -> AnyView?)? = nil,
        heightProvider: ((Option) -> CGFloat?)? = nil,
        onTap: @escaping (Option) -> Void
    ) {
        self.sections = sections
        self.onTap = onTap
        self.additionalTextProvider = additionalTextProvider
        self.rightViewProvider = rightViewProvider
        self.heightProvider = heightProvider
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(0 ..< sections.count, id: \.self) { sectionIndex in
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(sections[sectionIndex], id: \.self) { item in
                            VStack(alignment: .leading, spacing: 0) {
                                HStack {
                                    Text(item.rawValue)
                                    Spacer()

                                    if let additionalText = additionalTextProvider?(item) {
                                        Text(additionalText)
//                                            .opacity(0.5)
                                    }

                                    if let rightView = rightViewProvider?(item) {
                                        rightView
                                    } else {
                                        Image(systemName: "chevron.right")
                                    }
                                }
                                .font(.system(size: 14))
                                .frame(height: heightProvider?(item) ?? 55)
                                .padding(.horizontal, 16)
                                .background(Color.white)
                                .onTapGesture {
                                    onTap(item)
                                }

                                if item != sections[sectionIndex].last {
                                    Divider()
                                        .padding(.leading, 16)
                                }
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.vertical)
                }
            }
        }
        .background(Color(hex: 0xF8F5F5))
    }
}
