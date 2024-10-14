//
//  VerificationCodeViewController.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/12.
//

import UIKit

class VerificationCodeViewController: ViewController {
    var accountNum: String = ""
    var accountType: AccountType = .mobile
    var verificationCodeType: VerificationCodeType = .login

    override var rootView: AnyView? {
        return AnyView(
            VerificationCodeView(
                accountNum: accountNum,
                accountType: accountType,
                verificationCodeType: verificationCodeType
            )
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension VerificationCodeViewController {
    override func initUI() {
        super.initUI()
    }
}
