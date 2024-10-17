//
//  ViewModel.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/15.
//

import UIKit

class ViewModel: ObservableObject {
    static let shared = ViewModel()

    @Published var selectedModel = S.Config.mode {
        willSet {
            S.Config.mode = newValue
        }
    }

    @Published var openNoTrace: Bool = S.Config.openNoTrace {
        willSet {
            S.Config.openNoTrace = newValue
        }
    }

    private init() {}
}
