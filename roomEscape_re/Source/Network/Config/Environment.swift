//
//  Environment.swift
//  InsideROO
//
//  Created by jason on 02/02/2019.
//  Copyright © 2019 Dong Seok Lee. All rights reserved.
//

import Foundation
import UIKit

var storeUpdateId: Int = 0
var updateDiff: String = "category"
var updateId: Int = 0
var FcmToken: String = ""
//
var currentLocation: (Double, Double)?

struct ApiEnvironment {
  static let baseUrl = "http://3.37.169.42:31311"
  static let kakaoAppKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_APP_KEY") as! String
  static let kakaoRESTKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_REST_KEY") as! String
  //  static let serverGatewayStage = Bundle.main.object(forInfoDictionaryKey: "SERVER_GATEWAY_STAGE") as! String
  static let subBaseUrl = "http://52.78.226.88:33667"
}


enum http_method: String, Codable {
  case get = "GET"
  case post = "POST"
  case put = "PUT"
  case delete = "DELETE"
}
