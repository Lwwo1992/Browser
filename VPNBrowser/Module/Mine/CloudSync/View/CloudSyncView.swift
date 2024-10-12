//
//  CloudSyncView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/9.
//

import SwiftUI

struct CloudSyncView: View {
    @State private var isOn = false

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "star.circle")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)

                VStack(alignment: .leading, spacing: 5) {
                    Text("收藏云同步")
                        .font(.system(size: 16))
                    Text("刚刚同步")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }

                Spacer()

                Image(systemName: "chevron.forward")
                    .foregroundColor(.gray)
            }
            .frame(height: 80)
            .padding(.horizontal, 16)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)

//            HStack {
//                Image(systemName: "cursorarrow.click.badge.clock")
//                    .font(.system(size: 40))
//                    .foregroundColor(.blue)
//
//                VStack(alignment: .leading, spacing: 5) {
//                    Text("密码云同步")
//                        .font(.system(size: 16))
//                    Text("5分钟前")
//                        .font(.system(size: 12))
//                        .foregroundColor(.gray)
//                }
//
//                Spacer()
//
//                Toggle("", isOn: $isOn)
//                    .labelsHidden()
//            }
//            .frame(height: 80)
//            .padding(.horizontal, 16)
//            .background(Color.gray.opacity(0.1))
//            .cornerRadius(10)

            Spacer()

            Button {
            } label: {
                Text("一键同步")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(25)
            }
        }
        .padding()
    }
}

#Preview {
    CloudSyncView()
}
