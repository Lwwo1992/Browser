//
//  RecommendedModeView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/9.
//

import SwiftUI

struct RecommendedModeView: View {
    enum RecommendedModeOption: String, CaseIterable {
        case webMode = "导航(web)"
        case guideMode = "应用(guide)"
    }

    @State private var selectedOption: RecommendedModeOption? = .webMode

    var body: some View {
        VStack {
            VStack(spacing: 0) {
                ForEach(RecommendedModeOption.allCases, id: \.self) { option in
                    HStack {
                        Text(option.rawValue)
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                        Spacer()

                        if option == selectedOption {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .frame(height: 55)
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .onTapGesture {
                        selectedOption = option
                    }

                    if option != RecommendedModeOption.allCases.last {
                        Divider()
                            .padding(.leading, 16)
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(10)
            .padding(.horizontal, 16)

            Spacer()
        }
        .padding(.top, 8)
        .background(Color(hex: 0xF8F5F5))
    }
}

#Preview {
    RecommendedModeView()
}
