//
//  CustomTextField.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/12.
//

import SwiftUI

struct CustomTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.isSecureTextEntry = isSecure
        textField.keyboardType = keyboardType
        textField.borderStyle = .none
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidChange(_:)), for: .editingChanged)
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        uiView.isSecureTextEntry = isSecure
        uiView.keyboardType = keyboardType
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: CustomTextField

        init(_ parent: CustomTextField) {
            self.parent = parent
        }

        @objc func textFieldDidChange(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
    }
}
