//
//  MineViewController.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/8.
//

import SwiftUI
import UIKit

class MineViewController: ViewController {
    override var rootView: AnyView? {
        return AnyView(MineView())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if LoginManager.shared.info.logintype == "1" {
            APIProvider.shared.request(.browserAccount(userId: LoginManager.shared.info.id), model: LoginModel.self) { result in
                switch result {
                case let .success(model):
                    DBaseManager.share.updateToDb(table: S.Table.loginInfo,
                                                  on: [
                                                    LoginModel.Properties.name,
                                                    LoginModel.Properties.account,
                                                    LoginModel.Properties.mailbox,
                                                    LoginModel.Properties.mobile,
                                                    LoginModel.Properties.createTime,
                                                  ],
                                                  with: model)
                    
                case let .failure(error):
                    print("Request failed with error: \(error)")
                }
            }
        }
    }
}

extension MineViewController {
    override func initUI() {
        super.initUI()
    }
}
