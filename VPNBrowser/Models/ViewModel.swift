//
//  ViewModel.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/15.
//

import UIKit

class ViewModel: ObservableObject {
    static let shared = ViewModel()
    
    /// 用户判断是否需要刷新web
    @Published var updateWeb = true

    @Published var selectedModel = S.Config.mode {
        willSet {
            updateWeb = true
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
