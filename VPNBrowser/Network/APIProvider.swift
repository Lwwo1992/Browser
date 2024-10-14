//
//  APIManager.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/11.
//

import HandyJSON
import Moya

class APIProvider {
    static let shared = MoyaProvider<APITarget>()

    private init() {}
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

    case rankingPage
}

extension APITarget: TargetType {
    var baseURL: URL {
        return URL(string: "https://browser-api.xiwshijieheping.com")!
//        #if DEBUG
//            return URL(string: "https://browser-api.xiwshijieheping.com")!
//        #else
//            return URL(string: "http://browser-dev-api.saas-xy.com:81")!
//        #endif
    }

    var path: String {
        switch self {
        case .getConfigByType:
            return "/browser/app/anonymous/getConfigByType"
        case .sendSmsCode:
            return "/browser/app/auth/sendSmsCode"
        case .sendEmailCode:
            return "/browser/app/auth/sendEmailCode"
        case .login:
            return "/browser/app/auth/login"
        case .checkValidCode:
            return "/browser/app/browserAccount/checkValidCode"
        case .enginePage:
            return "/browser/app/anonymous/enginePage"
        case .logout:
            return "/browser/app/auth/logout"
        case .anonymousConfig:
            return "/browser/app/anonymous/config"
        case .updateEmailOrMobile:
            return "/browser/app/browserAccount/updateEmailOrMobile"
        case .rankingPage:
            return "/browser/app/anonymous/rankingPage"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getConfigByType, .sendSmsCode, .checkValidCode, .sendEmailCode, .enginePage, .login, .logout, .anonymousConfig, .updateEmailOrMobile, .rankingPage:
            return .post
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
            let data: [String: Any] = ["credential": credential, "identifier": identifier, "type": type]
            parameters = ["data": data]
        case .logout, .anonymousConfig:
            break
        }

        return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
    }

    var headers: [String: String]? {
        return [
            "Content-Type": "application/json",
            "AuthorizationApp": LoginManager.shared.loginInfo?.account ?? "",
        ]
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
                    print("未能将 JSON 解析为 BaseResponse")
                }

            case let .failure(error):
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
                            print("未能解析 'data' 字段。")
                        }
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            HUD.showTipMessage(baseResponse.message)
                        }
                        completion(.failure(NSError(domain: "APIError", code: -1, userInfo: [NSLocalizedDescriptionKey: baseResponse.message ?? "Unknown error"])))
                    }
                } else {
                    print("未能将 JSON 解析为 BaseResponse")
                }

            case let .failure(error):
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