//
//  AuthApi.swift
//  kospiKorea
//
//  Created by hoonKim on 2020/05/19.
//  Copyright © 2020 hoon Kim. All rights reserved.
//

import Foundation
import Alamofire

// 서버랑 통신하는 api 만드는 곳
enum AuthApi: ApiRouter {
  
  case login(loginId: String, password: String)
  case join(param: JoinRequest)
  case isExistLoginId(loginId: String)
  case sendCode(param: SendCodeRequest)
  case confirm(param: CheckphoneCodeRequest)
  case findId(param: FindMyIdRequest)
  case changePassword(param: ChangePasswordRequest)
  case userUpdate(param: UserUpdateRequest)
  
  var method: HTTPMethod{
    switch self{
      case .isExistLoginId,
           .sendCode,
           .findId,
           .confirm:
        return .get
      case .login,
           .join,
           .changePassword:
        return .post
    case .userUpdate:
      return .put
    }
  }
  
  var path: String{
    switch self{
      case .login : return "/v1/auth/login"
      case .join: return "/v1/auth/join"
        
      case .isExistLoginId: return "/v1/auth/existLoginId"
        
      case .sendCode : return "/v1/auth/CertificationNumberSMS"
      case .confirm : return "/v1/auth/confirm"
        
      case .findId : return "/v1/auth/findLoginId"
      case .changePassword : return "/v1/auth/passwordChange"
      
    case .userUpdate : return "/v1/user/update"
        
    }
  }
  
  func urlRequest() throws -> URLRequest {
    
    let url = try baseUrl.asURL()
    var urlRequest = URLRequest(url: url.appendingPathComponent(path))
    
    urlRequest.httpMethod = method.rawValue
    
    switch self {
      
      case .login(let loginId, let password) :
        urlRequest = try URLEncoding.default.encode(urlRequest, with: ["loginId": loginId, "password": password])
        
      case .join(let param):
        urlRequest = try URLEncoding.default.encode(urlRequest, with: makeParams(param))
        
      case .isExistLoginId(let loginId):
        urlRequest = try URLEncoding.default.encode(urlRequest, with: ["loginId": loginId])
        
      case .sendCode(let param) :
        urlRequest = try URLEncoding.default.encode(urlRequest, with: makeParams(param))
      case .confirm(let param) :
        urlRequest = try URLEncoding.queryString.encode(urlRequest, with: makeParams(param))
      case .changePassword(let param) :
        urlRequest = try URLEncoding.default.encode(urlRequest, with: makeParams(param))
      case .findId(let param) :
        urlRequest = try URLEncoding.default.encode(urlRequest, with: makeParams(param))
      
    case .userUpdate(let param) :
      urlRequest = try URLEncoding.default.encode(urlRequest, with: makeParams(param))
    }
    return urlRequest
  }
  
  #if DEBUG
  var fakeFile: String? {
    return nil
  }
  #endif
}
