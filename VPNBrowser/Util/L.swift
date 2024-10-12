//
//  Config.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/11.
//

import Foundation

struct L {
    struct Table {
        static let configInfo = "configTable"
        static let loginInfo = "loginInfoTable"
    }

    struct config {
        static var maxAppNum = 5
        static var defalutUrl = ""
        static var loginType: [LoginType]?
    }
}
