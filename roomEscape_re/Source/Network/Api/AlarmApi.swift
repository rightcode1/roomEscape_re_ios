//
//  AlarmApi.swift
//  roomEscape_re
//
//  Created by 이남기 on 4/18/24.
//

import Foundation
import Alamofire

enum AlarmApi: ApiRouter {
  
  case alarmThemeList
  case alarmHistoryList
  case alarmThemeRegister(param: RegistAlarmTheme)
  
  var method: HTTPMethod{
    switch self{
      case .alarmThemeList,
           .alarmHistoryList:
        return .get
    case .alarmThemeRegister:
      return .post

    }
  }
  
  var path: String{
    switch self{
      case .alarmHistoryList: return "/v1/alertHistory/list"
      case .alarmThemeList: return "/v1/alert/list"
      case .alarmThemeRegister: return "/v1/alert/register"
    }
  }
  
  func urlRequest() throws -> URLRequest {
    
    let url = try ApiEnvironment.baseUrl.asURL()
    var urlRequest = URLRequest(url: url.appendingPathComponent(path))
    
    urlRequest.httpMethod = method.rawValue
    urlRequest.addValue(DataHelperTool.token ?? "", forHTTPHeaderField: "Authorization")
    
    switch self {
      case .alarmThemeList:
      urlRequest = try URLEncoding.queryString.encode(urlRequest, with: ["userId": DataHelperTool.userAppId ?? 0])
      case .alarmHistoryList:
        urlRequest = try URLEncoding.queryString.encode(urlRequest, with: ["userId": DataHelperTool.userAppId ?? 0])
    case .alarmThemeRegister(let param):
      urlRequest = try URLEncoding.httpBody.encode(urlRequest, with: makeParams(param))
    }
    return urlRequest
  }
  
  #if DEBUG
  var fakeFile: String? {
    return nil
  }
  #endif
}

struct AlarmThemeListResponse: Codable {
  let statusCode: Int
  let message: String
  let list: [AlarmTheme]
}
struct AlarmTheme: Codable {
    let diff: [String]
    let theme: ThemaListData
}

struct AlarmHistoryListResponse: Codable {
  let statusCode: Int
  let message: String
  let list: [AlarmHistory]
}
struct AlarmHistory: Codable {
    let diff: String?
    let content: String?
    let createdAt: String?
    let theme: Theme
}
