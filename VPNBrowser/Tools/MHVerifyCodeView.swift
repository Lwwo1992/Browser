//
//  MHVerifyCodeView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/12.
//

import UIKit

class VerifyCodeSingleView: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 0.5
        layer.cornerRadius = 5
//        layer.masksToBounds = true
        textAlignment = .center
        font = UIFont.systemFont(ofSize: 16)
        textColor = .black
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    }
}

public class MHVerifyCodeView: UIStackView, UITextFieldDelegate {
    var verifyCodes: [VerifyCodeSingleView]!

    /** 验证码字体 */
    public var font: UIFont = UIFont.systemFont(ofSize: 16) {
        didSet {
            for verifyCode in verifyCodes {
                verifyCode.font = font
            }
        }
    }

    /** 验证码数量 */
    public var verifyCount: Int? {
        didSet {
            for _ in Range(0 ... (verifyCount ?? 4) - 1) {
                let singleView = VerifyCodeSingleView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
                verifyCodes.append(singleView)
                addArrangedSubview(singleView)
            }
        }
    }

    /** 验证码输入完成后的回调闭包，返回参数为验证码 */
    var completeHandler: ((_ verifyCode: String) -> Void)!

    // 隐藏的输入框
    lazy var hideTextField: UITextField = {
        let textfield = UITextField()
        self.addSubview(textfield)
        textfield.isHidden = true
        textfield.keyboardType = .numberPad
        textfield.delegate = self
        return textfield
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .horizontal
        distribution = .fillEqually
        verifyCodes = []
        verifyCount = 4
    }

    /**
     - parameter complete: 验证完成回调闭包，返回参数为验证码
     */
    public convenience init(complete: @escaping (_ verifyCode: String) -> Void) {
        self.init()
        setCompleteHandler(complete: complete)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /** 设置验证码输入完成后的回调闭包 */
    public func setCompleteHandler(complete: @escaping (_ verifyCode: String) -> Void) {
        completeHandler = complete
    }

    public func textFieldDidChangeSelection(_ textField: UITextField) {
        guard textField.text!.count <= (verifyCount ?? 4) else {
            textField.text = String(textField.text!.prefix(4))
            return
        }

        var index = 0
        for char in textField.text! {
            verifyCodes[index].text = String(char)
            index += 1
        }
        guard index < (verifyCount ?? 4) else {
            endEditing(true)

            if let complete = completeHandler {
                complete(textField.text!)
            }
            return
        }
        for i in Range(index ... (verifyCount ?? 4) - 1) {
            verifyCodes[i].text = ""
        }
    }

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        hideTextField.becomeFirstResponder()
    }
}
