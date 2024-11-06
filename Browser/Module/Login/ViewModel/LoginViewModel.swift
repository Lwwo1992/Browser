//
//  LoginViewModel.swift
//  Browser
//
//  Created by xyxy on 2024/10/23.
//

import Combine
import UIKit

class LoginViewModel: ObservableObject {
    @Published var isAgree = false
    @Published var showAgreeSheet = false
    @Published var mobile: String = ""
    @Published var mailbox: String = ""
    @Published var showMobileTextField = true
    @Published var showMailboxTextField = false

    private var cancellables = Set<AnyCancellable>()

    init() {
        $showAgreeSheet
            .dropFirst()
            .sink { value in
                if value {
                    let v = AgreedBottomSheet(frame: CGRect(x: 0, y: 0, width: Util.deviceWidth, height: 260))
                    v.onAgreed = { [weak self] in
                        guard let self else { return }
                        self.isAgree = true
                        Util.topViewController().navigationController?.pushViewController(AccountLoginViewController(), animated: true)
                    }
                    v.tf_showSlide(Util.topViewController().view, direction: .bottom)
                }
            }
            .store(in: &cancellables)
    }

    func nextButtonAction() {
        if showMobileTextField {
            handleInputValidation(
                input: mobile,
                validationMethod: Util.isValidPhoneNumber,
                errorMessage: "手机号码格式错误",
                sendCodeMethod: sendSmsode
            )
        } else if showMailboxTextField {
            handleInputValidation(
                input: mailbox,
                validationMethod: Util.isValidEmail,
                errorMessage: "邮箱格式错误",
                sendCodeMethod: sendEmailCode
            )
        }
    }

    private func handleInputValidation(input: String, validationMethod: (String) -> Bool, errorMessage: String, sendCodeMethod: @escaping () -> Void) {
        if validationMethod(input) {
            if isAgree == false {
                Util.topViewController().popup.bottomSheet {
                    let v = AgreedBottomSheet(frame: CGRect(x: 0, y: 0, width: Util.deviceWidth, height: 260))
                    v.onAgreed = { [weak self] in
                        guard let self else { return }
                        self.isAgree = true
                        sendCodeMethod()
                    }
                    return v
                }
            } else {
                isAgree = true
                sendCodeMethod()
            }
        } else {
            HUD.showTipMessage(errorMessage)
        }
    }

    private func sendSmsode() {
        HUD.showLoading()
        APIProvider.shared.request(.sendSmsCode(mobile: mobile, nation: "+86")) { [weak self] result in
            guard let self else { return }
            HUD.hideNow()
            switch result {
            case .success:
                let vc = VerificationCodeViewController()
                vc.accountNum = "" + mobile
                vc.accountType = .mobile
                Util.topViewController().navigationController?.pushViewController(vc, animated: true)
            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }

    private func sendEmailCode() {
        HUD.showLoading()
        APIProvider.shared.request(.sendEmailCode(mailbox: mailbox)) { [weak self] result in
            guard let self else { return }
            HUD.hideNow()
            switch result {
            case .success:
                let vc = VerificationCodeViewController()
                vc.accountNum = mailbox
                vc.accountType = .mailbox
                Util.topViewController().navigationController?.pushViewController(vc, animated: true)
            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }
}
