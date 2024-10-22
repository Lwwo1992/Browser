//
//  MarketDetailView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/22.
//

import SwiftUI

struct MarketDetailView: View {
    @ObservedObject var viewModel =  HomeViewModel()

    var body: some View {
        VStack {
        }
        .onAppear {
            viewModel.fetchMarketDetail()
        }
    }
}

#Preview {
    MarketDetailView()
}
