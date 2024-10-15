//
//  ViewModel.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/15.
//

import UIKit

class ViewModel: ObservableObject {
    @Published var selectedModel = S.Config.mode
}
