//
//  BoardApi.swift
//  ppuryo
//
//  Created by hoonKim on 2021/05/27.
//

import Foundation
import Alamofire

var boardUpdateId: Int = 0

enum BoardApi: ApiRouter {
  
  case boardList(param: BoardListRequest)
  case boardDetail(id: Int)
  
  case registBoard(param: RegistBoardRequest)
  case modifyBoard(param: ModifyBoardRequest)
  case boardRemove(id: Int)
  
  case registBoardImage(boardId: Int)
  case removeBoardImage(id: Int)
  
  case registLike(boardId: Int)
  case removeLike(boardId: Int)
  
  case boardCommentList(boardId: Int)
  case boardCommentRegister(param: BoardCommentRegistRequest)
  case boardCommentRemover(id: Int)
  
  
  var method: HTTPMethod{
    switch self{
      case .boardList,
           .boardDetail,
           .boardCommentList:
        return .get
      case .boardCommentRegister,
           .registLike,
           .registBoard,
           .registBoardImage:
        return .post
      case .modifyBoard:
        return .put
      case .boardRemove,
           .removeLike,
           .boardCommentRemover,
           .removeBoardImage:
        return .delete
    }
  }
  
  var path: String{
    switch self{
        
      case .boardList: return "/v1/board/list"
      case .boardDetail: return "/v1/board/detail"
        
      case .registBoard: return "/v1/board/register"
      case .modifyBoard: return "/v1/board/update?id=\(boardUpdateId)"
      case .boardRemove: return "/v1/board/remove"

      case .registBoardImage: return "/v1/boardImage/register"
      case .removeBoardImage: return "/v1/boardImage/remove"
        
      case .registLike: return "/v1/like/register"
      case .removeLike: return "/v1/like/remove"
        
      case .boardCommentList: return "/v1/boardComment/list"
      case .boardCommentRegister: return "/v1/boardComment/register"
      case .boardCommentRemover: return "/v1/boardComment/remove"
      
    }
  }
  
  func urlRequest() throws -> URLRequest {
    
    let url = try ApiEnvironment.subBaseUrl.asURL()
    var urlRequest = URLRequest(url: url.appendingPathComponent(path))
    
    urlRequest.httpMethod = method.rawValue
    
    let urlStr: String = "\(ApiEnvironment.subBaseUrl)\(path)"
    let encoded  = urlStr.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
    var urlRequest2 = URLRequest(url: URL(string: encoded!)!)
    urlRequest2.httpMethod = method.rawValue
    
    let userPk = "\(DataHelperTool.userAppId ?? 0)"
    
    switch self {
      case .boardList(let param):
        urlRequest = try URLEncoding.queryString.encode(urlRequest, with: makeParams(param))
      case .boardDetail(let id):
        urlRequest = try URLEncoding.queryString.encode(urlRequest, with: ["id": id])
        
      case .registBoard(let param):
        urlRequest = try URLEncoding.default.encode(urlRequest, with: makeParams(param))
        urlRequest.addValue(userPk, forHTTPHeaderField: "Authorization")
      case .modifyBoard(let param):
        urlRequest = try URLEncoding.default.encode(urlRequest2, with: makeParams(param))
        urlRequest.addValue(userPk, forHTTPHeaderField: "Authorization")
        
      case .boardRemove(let id):
        urlRequest = try URLEncoding.queryString.encode(urlRequest, with: ["id": id])
        urlRequest.addValue(userPk, forHTTPHeaderField: "Authorization")
        
      case .registBoardImage(let boardId):
        urlRequest = try URLEncoding.queryString.encode(urlRequest, with: ["boardId": boardId])
        urlRequest.addValue(userPk, forHTTPHeaderField: "Authorization")
      case .removeBoardImage(let id):
        urlRequest = try URLEncoding.queryString.encode(urlRequest, with: ["id": id])
        urlRequest.addValue(userPk, forHTTPHeaderField: "Authorization")
        
      case .registLike(let boardId):
        urlRequest = try URLEncoding.default.encode(urlRequest, with: ["boardId": boardId])
        urlRequest.addValue(userPk, forHTTPHeaderField: "Authorization")
      case .removeLike(let boardId):
        urlRequest = try URLEncoding.default.encode(urlRequest, with: ["boardId": boardId])
        
      case .boardCommentList(let boardId):
      urlRequest = try URLEncoding.queryString.encode(urlRequest, with: ["boardId": boardId])
        
      case .boardCommentRegister(let param):
        urlRequest = try URLEncoding.default.encode(urlRequest, with: makeParams(param))
        urlRequest.addValue(userPk, forHTTPHeaderField: "Authorization")
      case .boardCommentRemover(let id):
        urlRequest = try URLEncoding.queryString.encode(urlRequest, with: ["id": id])
        urlRequest.addValue(userPk, forHTTPHeaderField: "Authorization")
    }
    return urlRequest
  }
  
  #if DEBUG
  var fakeFile: String? {
    return nil
  }
  #endif
}
