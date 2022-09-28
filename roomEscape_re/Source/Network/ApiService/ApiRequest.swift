//
//  ApiRequest.swift
//  BARO
//
//  Created by ldong on 2018. 1. 26..
//  Copyright © 2018년 weplanet. All rights reserved.
//

import Foundation
import Alamofire

protocol Cancelable {
    
    func cancel()
}

extension Request: Cancelable {
  func cancel() {
    
  }
}

struct ApiRequest {
    
    let request: Cancelable
    
    init(request: Cancelable) {
        self.request = request
    }
    
    func cancel() {
        request.cancel()
    }
}


struct MockRequest: Cancelable  {
    
    let urlRequest: URLRequest?
    
    init(router: ApiRouter) {
        if let urlRequest = try? router.asURLRequest() {
            self.urlRequest = urlRequest
        }
        else {
            assertionFailure("urlRequest cannot be nil")
            urlRequest = nil
        }
    }
    
    func cancel() {
        debugPrint("Canceled Mock Request")
    }
}
