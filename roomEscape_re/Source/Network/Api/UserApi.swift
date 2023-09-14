//
//  UserApi.swift
//  roomEscape_re
//
//  Created by hoon Kim on 2022/02/04.
//

import Foundation
import Alamofire

enum UserApi: ApiRouter {
  
  case userInfo
  case userOut
  case userGraduation
  case statistics
  
  var method: HTTPMethod{
    switch self{
    case .userInfo,
        .userGraduation,
        .statistics:
      return .get
    case .userOut:
      return .delete
    }
  }
  
  var path: String{
    switch self{
    case .userInfo : return "/v1/user/info"
    case .userOut : return "/v1/user/withdrawal"
    case .userGraduation : return "/v1/user/graduation"
    case .statistics : return "/v1/company/statistics"
    }
  }
  
  func urlRequest() throws -> URLRequest {
    
    let url = try baseUrl.asURL()
    var urlRequest = URLRequest(url: url.appendingPathComponent(path))
    
    urlRequest.httpMethod = method.rawValue
    
    switch self {
    case .userInfo:
      urlRequest = try URLEncoding.default.encode(urlRequest, with: nil)
      urlRequest.addValue(DataHelperTool.token ?? "", forHTTPHeaderField: "Authorization")
      
      case .userGraduation:
        urlRequest = try URLEncoding.default.encode(urlRequest, with: nil)
        urlRequest.addValue(DataHelperTool.token ?? "", forHTTPHeaderField: "Authorization")
      
      case .userOut:
        urlRequest = try URLEncoding.default.encode(urlRequest, with: nil)
        urlRequest.addValue(DataHelperTool.token ?? "", forHTTPHeaderField: "Authorization")
    case .statistics:
      urlRequest = try URLEncoding.default.encode(urlRequest, with: nil)
      urlRequest.addValue(DataHelperTool.token ?? "", forHTTPHeaderField: "Authorization")
    }
    return urlRequest
  }
  
#if DEBUG
  var fakeFile: String? {
    return nil
  }
#endif
}
