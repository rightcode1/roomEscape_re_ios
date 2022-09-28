//
//  ApiService.swift
//  BARO
//
//  Created by ldong on 2018. 1. 26..
//  Copyright © 2018년 weplanet. All rights reserved.
//

import UIKit
import Alamofire

typealias SuccessHanler<T: Codable> = (ApiResponse<T>) -> Void
typealias SuccessStringHandler = (String) -> Void
typealias SuccessDataHandler = (Data) -> Void
typealias FailureHanler = (ApiResponse<[ErrorMessage]>?) -> Void
typealias MultiPartFormHanler = (MultipartFormData) -> Void
typealias JsonHanler = (ApiResponse<Any>) -> Void

struct ApiService {
  
  #if MOCK
  static var manager: ApiManager = FakeApiManager()
  #else
  static var manager: ApiManager = RealApiManager()
  
  #endif
  
  var manager: ApiManager
  
  init(manager: ApiManager) {
    self.manager = manager
    
  }
  
  @discardableResult
  static func request(router: ApiRouter, success: @escaping JsonHanler, failure: FailureHanler?) -> ApiRequest {
    return manager.request(router: router, success: success, failure: failure)
  }
  
  @discardableResult
  static func request<T: Codable>(router: ApiRouter, success: @escaping SuccessHanler<[T]>, failure: FailureHanler?) -> ApiRequest {
    return manager.request(router: router, success: success, failure: failure)
  }
  
  @discardableResult
  static func request(router: ApiRouter, success: @escaping SuccessStringHandler, failuer: FailureHanler?) -> ApiRequest {
    return manager.request(router: router, success: success, failure: failuer)
  }
  
  @discardableResult
  static func request(router: ApiRouter, success: @escaping SuccessDataHandler, failuer: FailureHanler?) -> ApiRequest {
    return manager.request(router: router, success: success, failure: failuer)
  }
  
  @discardableResult
  static func request<T: Codable>(router: ApiRouter, success: @escaping SuccessHanler<T>, failure: FailureHanler?) -> ApiRequest {
    return manager.request(router: router, success: success, failure: failure)
  }
  
  static func upload<T: Codable>(router: ApiRouter, multiPartFormHanler: @escaping MultiPartFormHanler, success: @escaping SuccessHanler<T>, failure: FailureHanler?) {
    return manager.upload(router: router, multiPartFormHanler: multiPartFormHanler, success: success, failure: failure)
  }
  
  #if DEBUG
  @discardableResult
  static func requestStub<T: Codable>(router: ApiRouter,
                                      status: Int,
                                      response: ApiResponse<T>?,
                                      completion:@escaping (ApiResponse<T>) -> ()) -> ApiRequest {
    
    return MockApiManager().requestStub(router: router,
                                        status: status,
                                        response: response,
                                        completion: completion)
  }
  #endif
}




