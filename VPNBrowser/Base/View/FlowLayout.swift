//
//  hhh.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/12.
//

import SwiftUI

import SwiftUI

struct FlowLayout<Content: View>: View {
    var items: [String] // 可以更改为你的数据类型
    let content: (String) -> Content

    var body: some View {
        var totalWidth: CGFloat = 0
        var row: [String] = []
        let spacing: CGFloat = 8 // 定义元素之间的间距

        return VStack(alignment: .leading) {
            GeometryReader { geometry in
                ForEach(items, id: \.self) { item in
                    content(item)
                        .background(GeometryReader { geo in
                            Color.clear.preference(key: SizePreferenceKey.self, value: geo.size)
                        })
                        .onPreferenceChange(SizePreferenceKey.self) { size in
                            if totalWidth + size.width + spacing > geometry.size.width {
                                HStack {
                                    ForEach(row, id: \.self) { rowItem in
                                        content(rowItem)
                                    }
                                }
                                .padding(.bottom, 8)

                                // 清空当前行，并重置总宽度
                                row.removeAll()
                                totalWidth = 0
                            }

                            // 添加当前项目到当前行
                            row.append(item)
                            totalWidth += size.width + spacing // 加上间距
                        }
                }

                // 渲染最后一行
                if !row.isEmpty {
                    HStack {
                        ForEach(row, id: \.self) { rowItem in
                            content(rowItem)
                        }
                    }
                }
            }
        }
    }
}

// PreferenceKey 用于获取视图大小
struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
