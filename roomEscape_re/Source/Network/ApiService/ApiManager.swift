//
//  ApiManager.swift
//  BARO
//
//  Created by ldong on 2018. 1. 26..
//  Copyright © 2018년 weplanet. All rights reserved.
//


import Foundation
import Alamofire
import CodableAlamofire
import SwiftyJSON
//import SVProgressHUD

protocol ApiManager {
  func request<T: Codable>(router: ApiRouter, success: @escaping SuccessHanler<T>, failure: FailureHanler?) -> ApiRequest
  func request<T: Codable>(router: ApiRouter, success: @escaping SuccessHanler<[T]>, failure: FailureHanler?) -> ApiRequest
}

fileprivate var manager: Session = {
  return Alamofire.Session()
}()
 
fileprivate func reloadSessionManager() -> Session {
  //  var defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
  //    defaultHeaders["api_Key"] = ApiEnvironment.serverApiKey
  
  // USER TOKEN
  
  //  if let token = OPenPalManager.shared.getAccessToken() {
  //    defaultHeaders["Authorization"] = "Bearer \(token)"
  //  }
  
  let configuration = URLSessionConfiguration.default
  //  configuration.httpAdditionalHeaders = defaultHeaders
  
  let sessionManager = Alamofire.Session(configuration: configuration) 
  return sessionManager
}

extension ApiManager {
  
  func isSuccess(_ response: HTTPURLResponse?) -> Bool {
    var ret = false
    if let response = response, response.statusCode >= 200 && response.statusCode < 300 {
      ret = true
    }
    return ret
  }
  
  func reloadManager() {
    manager = reloadSessionManager()
  }
  
  func request(router: ApiRouter, success: @escaping SuccessStringHandler, failure: FailureHanler?) -> ApiRequest {
    let request = manager.request(router).validate()
    printDebug(request: request)
    
    request.responseData { (response) in
      if self.isSuccess(response.response), let wrappedResponse = String(data: response.data!, encoding: .utf8)?.components(separatedBy: .whitespacesAndNewlines).joined() {
        success(wrappedResponse)
      }
      else {
        let wrappedResponse = ApiResponse<[ErrorMessage]>(response: response)
        failure?(wrappedResponse)
      }
    }
    return ApiRequest(request: request)
  }
  
  func request(router: ApiRouter, success: @escaping SuccessDataHandler, failure: FailureHanler?) -> ApiRequest {
    let request = manager.request(router).validate()
    printDebug(request: request)
    
    request.responseData { (response) in
      if self.isSuccess(response.response), let wrappedResponse = response.data {
        success(wrappedResponse)
      }
      else {
        let wrappedResponse = ApiResponse<[ErrorMessage]>(response: response)
        failure?(wrappedResponse)
      }
    }
    return ApiRequest(request: request)
  }
  
  func request(router: ApiRouter, success: @escaping JsonHanler, failure: FailureHanler?) -> ApiRequest {
    let request = manager.request(router).validate()
    request.responseJSON { (response) in
      if self.isSuccess(response.response) {
        let wrappedResponse = ApiResponse<Any>(response: response)
        success(wrappedResponse)
      }
      else {
        let wrappedResponse = ApiResponse<[ErrorMessage]>(response: response)
        failure?(wrappedResponse)
      }
    }
    return ApiRequest(request: request)
  }
  
  func upload<T: Codable>(router: ApiRouter, multiPartFormHanler: @escaping MultiPartFormHanler, success: @escaping SuccessHanler<T>, failure: FailureHanler?) {
    manager.upload(multipartFormData: multiPartFormHanler, with: router, usingThreshold: 10 * 1024 * 1024)
      .responseData { (dataResponse) in
        switch dataResponse.result {
          
          case .success(_):
            
            if self.isSuccess(dataResponse.response) {
              let wrappedResponse = ApiResponse<T>(response: dataResponse)
              success(wrappedResponse)
            } else {
              let wrappedResponse = ApiResponse<[ErrorMessage]>(response: dataResponse)
              failure?(wrappedResponse)
            }
            
          case .failure(_):
            failure?(nil)
        }
      }
  }
  
  //  func upload<T: Codable>(router: ApiRouter, multiPartFormHanler: @escaping MultiPartFormHanler, success: @escaping SuccessHanler<T>, failure: FailureHanler?) {
  //
  //    manager.upload(
  //      multipartFormData: multiPartFormHanler,
  //      usingThreshold: 10 * 1024 * 1024,
  //      with: router,
  //      encodingCompletion: { (encodingResult) in
  //
  //        switch encodingResult {
  //          case .success(let upload, _, _):
  //            printDebug(request: upload)
  //
  //            upload.responseDecodableObject(completionHandler: { (response: AFDataResponse<T>) in
  //              if self.isSuccess(response.response) {
  //                let wrappedResponse = ApiResponse<T>(response: response)
  //                success(wrappedResponse)
  //              }else {
  //                let wrappedResponse = ApiResponse<[ErrorMessage]>(response: response)
  //                failure?(wrappedResponse)
  //              }
  //            })
  //          case .failure(let encodingError):
  //            debugPrint(encodingError)
  //            failure?(nil)
  //        }
  //      })
  //  }
  
}

struct RealApiManager: ApiManager {
  
  func request<T: Codable>(router: ApiRouter, success: @escaping SuccessHanler<T>, failure: FailureHanler?) -> ApiRequest {
    
    let request = manager.request(router).validate()
    printDebug(request: request)
    
    request.responseDecodableObject(completionHandler: { (response: AFDataResponse<T>) in
      if self.isSuccess(response.response) {
        let wrappedResponse = ApiResponse<T>(response: response)
        success(wrappedResponse)
      }else {
        let wrappedResponse = ApiResponse<[ErrorMessage]>(statusCode: response.response?.statusCode, data: response.data)
        failure?(wrappedResponse)
      }
    })
    
    return ApiRequest(request: request)
  }
  
  func request<T: Codable>(router: ApiRouter, success: @escaping SuccessHanler<[T]>, failure: FailureHanler?) -> ApiRequest {
    let request = manager.request(router).validate()
    printDebug(request: request)
    
    request.responseDecodableObject(completionHandler: { (response: AFDataResponse<[T]>) in
      if self.isSuccess(response.response) {
        let wrappedResponse = ApiResponse<[T]>(response: response)
        success(wrappedResponse)
      }else {
        let wrappedResponse = ApiResponse<[ErrorMessage]>(statusCode: response.response?.statusCode, data: response.data)
        failure?(wrappedResponse)
      }
    })
    
    return ApiRequest(request: request)
  }
}

// MARK:- DEBUG
fileprivate func printDebug(request: DataRequest) {
  #if DEBUG
  request.responseData(completionHandler: { (response) in
    print("\n------------------------------------------------------------------------------------------------")
    var output: [String] = []
    output.append("[Request]: \(request)")
    
    if let httpHeader = request.request?.allHTTPHeaderFields {
      output.append("[Request Header]: \(httpHeader)")
    }
    
    if let httpBody = request.request?.httpBody {
      // output.append("[Request Data]: \(try! JSON(data: httpBody))")
      output.append("[Request Data utf8] \(String(data: httpBody, encoding: String.Encoding.utf8)!)")
      
    }
    output.append("[Response]: \(response)")
    
    if let value = response.data,
       let string = String(data: value, encoding: .utf8) {
      output.append("[Response Data String]: \(string.components(separatedBy: .whitespacesAndNewlines).joined())")
      output.append("[Response Data JSON]: \(JSON(parseJSON: string))")
    }
    else {
      output.append("[Data]: nil")
    }
    
    //output.append("[Result]: \(response.result.debugDescription)")
    //output.append("[Timeline]: \(response.timeline.debugDescription)")
    print(output.joined(separator: "\n"))
    print("------------------------------------------------------------------------------------------------\n")
  })
  #endif
}

#if DEBUG
struct FakeApiManager: ApiManager {
  
  func request<T: Codable>(router: ApiRouter, success: @escaping SuccessHanler<T>, failure: FailureHanler?) -> ApiRequest {
    let mockResponse = getMockResponse(router: router, status: 200) as ApiResponse<T>
    let mockRequest = MockRequest(router: router)
    success(mockResponse)
    return ApiRequest(request: mockRequest)
  }
  
  func request<T: Codable>(router: ApiRouter, success: @escaping SuccessHanler<[T]>, failure: FailureHanler?) -> ApiRequest {
    let mockResponse = getMockResponses(router: router, status: 200) as ApiResponse<[T]>
    let mockRequest = MockRequest(router: router)
    success(mockResponse)
    return ApiRequest(request: mockRequest)
  }
}


fileprivate func getMockResponse<T: Codable>(router: ApiRouter, status: Int) -> ApiResponse<T> {
  
  if let file = router.fakeFile, status >= 200 && status < 300 {
    let json = JSONFileReader.getJSONNamed(file)
    return ApiResponse<T>(statusCode: status, errorString: nil, response: json)
  }
  else {
    return ApiResponse<T>(statusCode: 400, errorString: "Mock Error", response: nil)
  }
}

fileprivate func getMockResponses<T: Codable>(router: ApiRouter, status: Int) -> ApiResponse<[T]> {
  
  if let file = router.fakeFile, status >= 200 && status < 300 {
    let json = JSONFileReader.getJSONNamed(file)
    return ApiResponse<[T]>(statusCode: status, errorString: nil, response: json)
  }
  else {
    return ApiResponse<[T]>(statusCode: 400, errorString: "Mock Error", response: nil)
  }
}


struct MockApiManager: ApiManager {
  
  func request<T: Codable>(router: ApiRouter, success: @escaping SuccessHanler<T>, failure: FailureHanler?) -> ApiRequest {
    let mockResponse = getMockResponse(router: router, status: 200) as ApiResponse<T>
    success(mockResponse)
    let mockRequest = MockRequest(router: router)
    return ApiRequest(request: mockRequest)
  }
  
  func request<T: Codable>(router: ApiRouter, success: @escaping SuccessHanler<[T]>, failure: FailureHanler?) -> ApiRequest {
    let mockResponse = getMockResponse(router: router, status: 200) as ApiResponse<[T]>
    success(mockResponse)
    let mockRequest = MockRequest(router: router)
    return ApiRequest(request: mockRequest)
  }
  
  func requestStub<T: Codable>(router: ApiRouter,
                               status: Int,
                               response: ApiResponse<T>?,
                               completion: @escaping (ApiResponse<T>) -> ()) -> ApiRequest {
    if let response = response {
      completion(response)
      let mockRequest = MockRequest(router: router)
      return ApiRequest(request: mockRequest)
    }
    else {
      return request(router: router, success: completion, failure: nil)
    }
  }
}
#endif


