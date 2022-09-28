//
//  EtcResponse.swift
//  BARO
//
//  Created by ldong on 2018. 1. 26..
//  Copyright © 2018년 weplanet. All rights reserved.
//

import Foundation

struct ErrorMessage: Decodable {
  var errorLog: [String]?
  var errorCode: String?
}

struct BoolResponse: Codable {
  var data: Bool?
}

struct ResultResponse: Codable {
  var result: Bool
  var result_msg: String
}

struct DefaultResponse: Codable {
  let statusCode: Int
  let message: String
}

struct DefaultCodeResponse: Codable {
  let statusCode: Int
  let message: String
}

struct DefaultIDResponse: Codable {
  let statusCode: Int
  let message: String
  let data: DefaultID?
}

struct DefaultID: Codable {
  let id: Int
}
