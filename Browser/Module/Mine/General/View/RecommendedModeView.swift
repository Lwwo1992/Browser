//
//  RecommendedModeView.swift
//  Browser
//
//  Created by xyxy on 2024/10/9.
//

import SwiftUI

enum WebMode: String, CaseIterable {
    case web = "导航"
    case guide = "应用"
}

struct RecommendedModeView: View {
    @ObservedObject var viewModel = ViewModel.shared

    var body: some View {
        VStack {
            VStack(spacing: 0) {
                ForEach(WebMode.allCases, id: \.self) { option in
                    HStack {
                        Text(option.rawValue)
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                        Spacer()

                        if option == viewModel.selectedModel {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .frame(height: 55)
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .onTapGesture {
                        viewModel.selectedModel = option
                    }

                    if option != WebMode.allCases.last {
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
