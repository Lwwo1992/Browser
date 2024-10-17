//
//  MineViewModel.swift
//  VPNBrowser
//
//  Created by wei Chen on 2024/10/16.
//
import UIKit

class MineViewModel: ObservableObject {

    
    func fetchdata(success: @escaping () -> Void) {
        
        
        let m = LoginManager.shared.fetchUserModel()
        if m.logintype == "0"{
            return
        }
        
        let dataid  = LoginManager.shared.info.id
         
        APIProvider.shared.request(.browserAccount(userId: dataid), model: LoginModel.self) { result in

            switch result {
            case let .success(model  ):
                
                let mo = LoginManager.shared.fetchUserModel()
                model.token = mo.token

            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }

    }
    
}
