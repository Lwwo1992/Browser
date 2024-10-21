//
//  APIManager.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/11.
//

import Alamofire
import HandyJSON
import Moya

private let channelCode = "tomato"

class APIProvider {
    private let requestTimeout: TimeInterval = 30
    private let session: Session

    static let shared: MoyaProvider<APITarget> = {
        APIProvider().createProvider()
    }()

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = requestTimeout
        configuration.timeoutIntervalForResource = requestTimeout
        session = Session(configuration: configuration)
    }

    private func createProvider() -> MoyaProvider<APITarget> {
        return MoyaProvider<APITarget>(session: session)
    }
}

enum APITarget {
    /// 校验验证码
    /// 1-全局配置(数据在data) 2-隐私政策(数据在content) 3-服务条款(数据content)
    case getConfigByType(data: Int)

    /// 发送短信验证码
    /// mobile: 电话
    /// nation: 地区
    case sendSmsCode(mobile: String, nation: String)

    /// 发送邮箱验证码
    case sendEmailCode(mailbox: String)

    /// 登录
    /// credential: 密码/验证码
    /// identifier: 账号/手机/邮箱
    /// type: 登录类型：1-账号密码，2-电话，3-邮箱
    case login(credential: String, identifier: String, type: Int)

    /// 退出登录
    case logout

    /// 校验验证码
    /// credential: 密码/验证码
    /// identifier: 账号/手机/邮箱
    /// type: 登录类型：1-账号密码，2-电话，3-邮箱
    case checkValidCode(credential: String, identifier: String, type: Int)

    /// 获取搜索引擎分页列表
    case enginePage

    case anonymousConfig

    /// 修改邮箱-手机
    /// credential: 密码/验证码
    /// identifier: 账号/手机/邮箱
    /// type: 登录类型：1-账号密码，2-电话，3-邮箱
    case updateEmailOrMobile(credential: String, identifier: String, type: Int)

    /// 编辑用户资料
    case editUserInfo(headPortrait: String, name: String, id: String)

    /// 上传
    case uploadConfig

    case rankingPage

    /// 获取分类
    case guideLabelPage

    /// 获取导航应用
    case guideAppPage(labelID: String)

    /// 生成游客令牌
    case generateVisitorToken

    /// 获取分页列表(使用指南)
    case userGuidePage

    /// 查询用户信息
    case browserAccount(userId: String)

    /// 忘记密码
    case forgetPassword(password: String)

    /// 修改密码
    case updatePassword(new: String, old: String)

    /// 同步书签
    case syncBookmark(data: [Dictionary<String, Any>])
}

extension APITarget: TargetType {
    var baseURL: URL {
        switch self {
        case .guideLabelPage, .guideAppPage:
            // "http://guide-h5.saas-xy.com:89" //正式环境
            // "http://guide-api.saas-xy.com:86" //测试环境
            return URL(string: "http://guide-api.saas-xy.com:86")!
        default:
            return URL(string: "https://browser-api.xiwshijieheping.com")!
//            return URL(string: "http://browser-dev-api.saas-xy.com:81")!
        }
    }

    var path: String {
        switch self {
        case .guideLabelPage:
            return "/guide/h5/label/page"
        case .guideAppPage:
            return "/guide/h5/app/page"
        case .getConfigByType:
            return "/browser/app/visitorAccess/getConfigByType"
        case .sendSmsCode:
            return "/browser/app/visitorAccess/sendSmsCode"
        case .sendEmailCode:
            return "/browser/app/visitorAccess/sendEmailCode"
        case .login:
            return "/browser/app/visitorAccess/login"
        case .checkValidCode:
            return "/browser/app/browserAccount/checkValidCode"
        case .enginePage:
            return "/browser/app/visitorAccess/enginePage"
        case .logout:
            return "/browser/app/visitorAccess/logout"
        case .anonymousConfig:
            return "/browser/app/visitorAccess/config"
        case .updateEmailOrMobile:
            return "/browser/app/browserAccount/updateEmailOrMobile"
        case .rankingPage:
            return "/browser/app/visitorAccess/rankingPage"
        case .editUserInfo:
            return "/browser/app/browserAccount/edit"
        case .uploadConfig:
            return "/browser/app/visitorAccess/config"
        case .userGuidePage:
            return "/browser/app/visitorAccess/userGuidePage"
        case .generateVisitorToken:
            return "/browser/app/anonymous/generateVisitorToken"
        case let .browserAccount(id):
            return "/browser/app/browserAccount/\(id)"
        case .forgetPassword:
            return "/browser/app/browserAccount/forgetPassword"
        case .updatePassword:
            return "/browser/app/browserAccount/updatePassword"
        case .syncBookmark:
            return "/browser/app/browserBookmarkCollect/syncBookmark"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getConfigByType, .sendSmsCode, .checkValidCode, .sendEmailCode, .enginePage, .login, .logout, .anonymousConfig, .updateEmailOrMobile, .rankingPage, .editUserInfo, .uploadConfig, .guideAppPage, .guideLabelPage, .generateVisitorToken, .userGuidePage, .forgetPassword, .updatePassword, .syncBookmark:
            return .post

        case .browserAccount:
            return .get
        }
    }

    var task: Task {
        var parameters: [String: Any] = [:]

        switch self {
        case let .getConfigByType(data):
            parameters = ["data": data]
        case let .sendSmsCode(mobile, nation):
            let data: [String: Any] = ["mobile": mobile, "nation": nation]
            parameters = ["data": data]
        case let .sendEmailCode(mailbox):
            parameters = ["data": mailbox]
        case .enginePage:
            parameters = ["data": ["state": 1], "fetchAll": true, "pageIndex": 1, "pageSize": 10]
        case .rankingPage:
            parameters = ["data": ["hotList": 1], "pageIndex": 1, "pageSize": 10]
        case let .login(credential, identifier, type),
             let .updateEmailOrMobile(credential, identifier, type),
             let .checkValidCode(credential, identifier, type):
            let uuid = UIDevice.current.identifierForVendor?.uuidString ?? ""
            let data: [String: Any] = ["credential": credential, "identifier": identifier, "type": type, "deviceId": uuid]
            parameters = ["data": data]

        case let .editUserInfo(headPortrait, name, id):
            var data: [String: Any] = [:]

            // 直接判断字符串是否为空
            if !headPortrait.isEmpty {
                data["headPortrait"] = headPortrait
            }
            if !name.isEmpty {
                data["name"] = name
            }

            data["id"] = id
            parameters = ["data": data]

        case .browserAccount:
            return .requestPlain

        case .guideLabelPage:
            let data: [String: Any] = [
                "channelCode": channelCode,
                "state": 1,
            ]
            parameters = ["data": data, "fetchAll": true, "pageIndex": 1, "pageSize": -1]
        case let .guideAppPage(labelID):
            let data: [String: Any] = [
                "channelCode": channelCode,
                "labelId": labelID,
                "state": 1,
            ]
            parameters = ["data": data, "fetchAll": true, "pageIndex": 1, "pageSize": -1]
        case .userGuidePage:
            let data: [String: Any] = [:]
            parameters = ["data": data, "fetchAll": true, "pageIndex": 1, "pageSize": 10]
        case .generateVisitorToken:

            if let uuid = UIDevice.current.identifierForVendor?.uuidString {
                parameters = ["data": ["deviceId": uuid]]
            }
        case let .forgetPassword(password):
            parameters = ["data": ["newPassword": password]]

        case let .updatePassword(new, old):
            parameters = ["data": ["newPassword": new, "oldPassword": old]]

        case let .syncBookmark(data):
            parameters = ["data": data]
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])

                // 将 jsonData 转换为字符串形式（如果需要）
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("JSON String: \(jsonString)")
                }

                // 继续将 jsonData 作为请求体进行网络请求
            } catch {
                print("Failed to convert parameters to JSON: \(error)")
            }
        case .logout, .anonymousConfig, .uploadConfig:
            break
        }

        return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
    }

    var headers: [String: String]? {
        switch self {
        case .guideAppPage, .guideLabelPage:
            return [
                "Content-Type": "application/json",
                "ClientAuthorization": TokenGenerator.generateTokenGuide(),
            ]
        default:
            var token = ""
            if LoginManager.shared.info.logintype == "0" {
                token = LoginManager.shared.info.vistoken
            } else {
                token = LoginManager.shared.info.token
            }
            return [
                "Content-Type": "application/json",
                "AuthorizationApp": token,
            ]
        }
    }
}

extension MoyaProvider {
    func request(_ target: Target, completion: @escaping (Result<BaseResponse<BaseModel>, Error>) -> Void) {
        printRequestInfo(for: target)

        request(target) { result in
            switch result {
            case let .success(response):
                guard let jsonString = String(data: response.data, encoding: .utf8) else {
                    print("Failed to convert data to JSON string.")
                    completion(.failure(NSError(domain: "HandyJSONError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert data to JSON string"])))
                    return
                }

                print("Response JSON: \(jsonString)") // 打印 JSON 数据

                if let baseResponse = BaseResponse<BaseModel>.deserialize(from: jsonString) {
                    if baseResponse.code == "0000" {
                        completion(.success(baseResponse))
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            HUD.showTipMessage(baseResponse.message)
                        }
                        completion(.failure(NSError(domain: "APIError", code: -1, userInfo: [NSLocalizedDescriptionKey: baseResponse.message ?? "Unknown error"])))
                    }
                } else {
                    HUD.hideNow()
                    print("未能将 JSON 解析为 BaseResponse")
                }

            case let .failure(error):
                HUD.hideNow()
                // 捕获网络请求失败的错误
                print("请求失败，出现错误: \(error)")
            }
        }
    }

    func request<T: HandyJSON>(_ target: Target, model: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        printRequestInfo(for: target)

        request(target) { result in
            switch result {
            case let .success(response):
                guard let jsonString = String(data: response.data, encoding: .utf8) else {
                    print("Failed to convert data to JSON string.")
                    completion(.failure(NSError(domain: "HandyJSONError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert data to JSON string"])))
                    return
                }

                print("Response JSON: \(jsonString)") // 打印 JSON 数据

                if let baseResponse = BaseResponse<T>.deserialize(from: jsonString) {
                    if baseResponse.code == "0000" {
                        if let decodedModel = baseResponse.data {
                            completion(.success(decodedModel))
                        } else {
                            HUD.hideNow()
                            print("未能解析 'data' 字段。")
                        }
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            HUD.showTipMessage(baseResponse.message)
                        }
                        completion(.failure(NSError(domain: "APIError", code: -1, userInfo: [NSLocalizedDescriptionKey: baseResponse.message ?? "Unknown error"])))
                    }
                } else {
                    HUD.hideNow()
                    print("未能将 JSON 解析为 BaseResponse")
                }

            case let .failure(error):
                HUD.hideNow()
                print("请求失败，出现错误: \(error)")
            }
        }
    }

    // 打印请求信息的方法
    private func printRequestInfo(for target: Target) {
        print("Request URL: \(target.baseURL.appendingPathComponent(target.path))")
        print("HTTP Method: \(target.method.rawValue)")

        if let headers = target.headers {
            print("Headers: \(headers)")
        } else {
            print("Headers: None")
        }

        switch target.task {
        case .requestPlain:
            print("Request Parameters: None")
        case let .requestData(data):
            print("Request Data: \(data)")
        case let .requestParameters(parameters, encoding):
            print("Request Parameters: \(parameters)")
            print("Parameter Encoding: \(encoding)")
        case let .requestCompositeData(_, urlParameters):
            print("URL Parameters: \(urlParameters)")
        case let .requestCompositeParameters(bodyParameters, bodyEncoding, urlParameters):
            print("Body Parameters: \(bodyParameters)")
            print("Body Encoding: \(bodyEncoding)")
            print("URL Parameters: \(urlParameters)")
        default:
            print("Request Task: Not supported for logging.")
        }
    }
}
