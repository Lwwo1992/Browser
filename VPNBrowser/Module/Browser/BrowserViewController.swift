//
//  BrowserViewController.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/8.
//

import UIKit

class BrowserViewController: ViewController {
    private lazy var browserHostingController: UIHostingController = {
        let rootView = BrowserView()
        let hosting = UIHostingController(rootView: rootView)
        hosting.view.backgroundColor = .clear
        return hosting
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        HUD.showLoading()
        config { [weak self] in
            guard let self else { return }
            HUD.hideNow()
            addChild(browserHostingController)
            view.addSubview(browserHostingController.view)
            browserHostingController.view.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(self.view.safeAreaTop)
            }
            browserHostingController.didMove(toParent: self)

            LoginManager.shared.fetchUserInfo()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
}

extension BrowserViewController {
    override func initUI() {
        super.initUI()
    }

    private func config(completion: (() -> Void)? = nil) {
        if LoginManager.shared.info.userType != .visitor && !LoginManager.shared.info.token.isEmpty {
            fetchConfigByType {
                self.fetchAnonymousConfig {
                    completion?()
                }
            }
        } else {
            APIProvider.shared.request(.generateVisitorToken, progress: { _ in

            }) { [weak self] result in
                guard let self else { return }
                switch result {
                case let .success(response):
                    if let responseString = String(data: response.data, encoding: .utf8) {
                        print("Response: \(responseString)")
                    }

                    do {
                        if let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: Any],
                           let data = json["data"] as? [String: Any],
                           let token = data["token"] as? String,
                           let userId = data["id"] as? String {
                            let model = LoginModel()
                            model.id = userId
                            model.userType = .visitor
                            model.vistoken = token

                            LoginManager.shared.info = model

                            if let array = DBaseManager.share.qureyFromDb(fromTable: S.Table.loginInfo, cls: LoginModel.self), !array.isEmpty {
                                DBaseManager.share.updateToDb(table: S.Table.loginInfo,
                                                              on: [
                                                                  LoginModel.Properties.id,
                                                                  LoginModel.Properties.vistoken,
                                                                  LoginModel.Properties.userTypeV,
                                                              ],
                                                              with: model)
                            } else {
                                DBaseManager.share.insertToDb(objects: [model], intoTable: S.Table.loginInfo)
                            }

                            // 配置获取成功
                            self.fetchConfigByType {
                                self.fetchAnonymousConfig {
                                    completion?() // 执行回调
                                }
                            }

                        } else {
                            print("无法提取 token")
                        }
                    } catch {
                        HUD.showTipMessage(error.localizedDescription)
                        print("JSON 解析失败: \(error)")
                    }

                case let .failure(error):
                    print("请求失败: \(error)")
                    HUD.showTipMessage(error.localizedDescription)
                }
            }
        }
    }

    private func fetchConfigByType(completion: (() -> Void)? = nil) {
        APIProvider.shared.request(.getConfigByType(data: 1), model: ConfigByTypeModel.self) { result in
            switch result {
            case let .success(model):
                if let data = model.data {
                    DBaseManager.share.insertToDb(objects: [data], intoTable: S.Table.configInfo)

                    S.Config.maxAppNum = data.maxAppNum ?? 5
                    S.Config.defalutUrl = data.defalutUrl ?? ""
                    S.Config.loginType = data.loginType
                }
                completion?()

            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }

    private func fetchAnonymousConfig(completion: (() -> Void)? = nil) {
        APIProvider.shared.request(.anonymousConfig, model: AnonymousConfigModel.self) { result in
            switch result {
            case let .success(model):
                S.Config.anonymous = model
                completion?()

            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }
}
