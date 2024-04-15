//
//  NotificationApi.swift
//  ppuryo
//
//  Created by hoonKim on 2021/05/07.
//

import Foundation
import Alamofire

enum NotificationApi: ApiRouter {
  
  case registNotificationToken(param: NotificationRequest)
  
  case notificationInfo(notificationToken: String)
  
  case updateNotification(notificationToken: String, active: String)
  
  case settingNotification(param: SettingNotificationRequest)
  
  var method: HTTPMethod{
    switch self{
      case .notificationInfo:
        return .get
      
      case .registNotificationToken:
        return .post
      case .updateNotification,
           .settingNotification:
        return .put
    }
  }
  
  var path: String{
    switch self{
      case .registNotificationToken : return "/v1/notification/register"
        
      case .notificationInfo: return "/v1/notification/detail"
        
      case .updateNotification: return "/v1/notification/update"
      case .settingNotification: return "/v1/user/update"
    }
  }
  
  func urlRequest() throws -> URLRequest {
    
    let url = try baseUrl.asURL()
    var urlRequest = URLRequest(url: url.appendingPathComponent(path))
    
    urlRequest.httpMethod = method.rawValue
    
    switch self {
      case .registNotificationToken(let param):
      urlRequest = try URLEncoding.httpBody.encode(urlRequest, with: makeParams(param))
      urlRequest.addValue(DataHelperTool.token ?? "", forHTTPHeaderField: "Authorization")
        
      case .notificationInfo(let notificationToken):
        urlRequest = try URLEncoding.queryString.encode(urlRequest, with: ["notificationToken": notificationToken])
        urlRequest.addValue(DataHelperTool.token ?? "", forHTTPHeaderField: "Authorization")
        
      case .updateNotification(let notificationToken, let active):
        urlRequest = try URLEncoding.queryString.encode(urlRequest, with: ["notificationToken": notificationToken, "active": active])
        urlRequest.addValue(DataHelperTool.token ?? "", forHTTPHeaderField: "Authorization")
        
      case .settingNotification(let param):
        urlRequest = try URLEncoding.default.encode(urlRequest, with: makeParams(param))
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

