//
//  NoticeBoardAPI.swift
//  roomEscape_re
//
//  Created by hoon Kim on 2022/03/16.
//

import Foundation
import Alamofire

enum NoticeBoardAPI: ApiRouter {
  
  case boardList(diff: String)
  case boardDetail(id: Int)
  
  var method: HTTPMethod{
    switch self{
      case .boardList,
           .boardDetail:
        return .get

    }
  }
  
  var path: String{
    switch self{
      case .boardList: return "/v1/board/list"
      case .boardDetail: return "/v1/board/detail"
    }
  }
  
  func urlRequest() throws -> URLRequest {
    
    let url = try ApiEnvironment.baseUrl.asURL()
    var urlRequest = URLRequest(url: url.appendingPathComponent(path))
    
    urlRequest.httpMethod = method.rawValue
    
    let urlStr: String = "\(ApiEnvironment.baseUrl)\(path)"
    let encoded  = urlStr.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
    var urlRequest2 = URLRequest(url: URL(string: encoded!)!)
    urlRequest2.httpMethod = method.rawValue
    
//    let userPk = "\(DataHelperTool.userAppId ?? 0)"
    
    switch self {
      case .boardList(let diff):
      urlRequest = try URLEncoding.queryString.encode(urlRequest, with: ["diff": diff])
      urlRequest.addValue(DataHelperTool.token ?? "", forHTTPHeaderField: "Authorization")
      case .boardDetail(let id):
        urlRequest = try URLEncoding.queryString.encode(urlRequest, with: ["id": id])
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
