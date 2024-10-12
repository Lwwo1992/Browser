//
//  LoginManager.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/12.
//

class LoginManager: ObservableObject {
    @Published var loginInfo: LoginModel? = nil

    static let shared = LoginManager()

    private init() {}
}
