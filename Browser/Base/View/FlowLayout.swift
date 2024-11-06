//
//  hhh.swift
//  Browser
//
//  Created by xyxy on 2024/10/12.
//

import SwiftUI

struct FlowLayout<Item: Identifiable, ItemView: View>: View {
    let items: [Item]
    let itemView: (Item) -> ItemView
    let horizontal: CGFloat = 8
    let vertical: CGFloat = 8

    @State private var totalHeight = CGFloat.zero

    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(self.items) { item in
                self.itemView(item)
                    .padding(.horizontal, horizontal / 2)
                    .padding(.vertical, vertical / 2)
                    .alignmentGuide(.leading, computeValue: { d in
                        if abs(width - d.width) > g.size.width {
                            width = 0
                            height -= d.height + vertical // 加入垂直间隔
                        }

                        let result = width
                        if item.id == self.items.last!.id {
                            width = 0 // last item
                        } else {
                            width -= d.width + horizontal // 加入水平间隔
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { _ in
                        let result = height
                        if item.id == self.items.last!.id {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }
        .background(viewHeightReader($totalHeight))
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}
