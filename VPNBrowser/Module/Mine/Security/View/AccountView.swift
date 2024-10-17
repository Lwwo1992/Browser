//
//  AccountView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/17.
//

import SDWebImageSwiftUI
import SwiftUI

struct AccountView: View {
    var body: some View {
        VStack(spacing: 10) {
            WebImage(url: URL(string: LoginManager.shared.info.headPortrait)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
            } placeholder: {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 60))
            }

            Text("当前账号: \(LoginManager.shared.info.account ?? "")")
                .font(.system(size: 14))

            Spacer()

            Button {
                Util.topViewController().navigationController?.pushViewController(ChangePasswordViewController(), animated: true)
            } label: {
                Text("修改密码")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(25)
            }
            .padding(.bottom, 20)
        }
        .padding(.top, 30)
        .padding(.horizontal, 16)
    }
}

#Preview {
    AccountView()
}
