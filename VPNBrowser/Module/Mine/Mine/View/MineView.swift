//
//  MineView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/8.
//

import SwiftUI

struct MineView: View {
    @State var model = LoginModel()
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            MineTopView(model: model)
            MineBottomView()
        }
        .padding(.horizontal, 16)
        .background(Color(hex: 0xF8F5F5))
        .onAppear{
            
//            MineViewModel().fetchdata {
//                DispatchQueue.main.async {
//                    model = LoginManager.shared.fetchUserModel()
//                    print("模型更新成功：\(model)")
//                }
//                 
//            }
           
        }
    }
}

#Preview {
    MineView()
}
