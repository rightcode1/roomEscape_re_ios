//
//  AuthResponse.swift
//  ppuryo
//
//  Created by hoonKim on 2021/05/06.
//

import Foundation

struct LoginResponse: Codable {
  let statusCode: Int
  let message: String
  let token: String?
  let role: String?
}

struct JoinResponse: Codable {
  let statusCode: Int
  let message: String
  let data: JoinIdData?
}

struct JoinIdData: Codable {
  let userId: Int
  let storeId: Int
}

struct FindIdResponse: Codable {
  let statusCode: Int
  let message: String
  let data: FindIdData?
}

struct FindIdData: Codable {
  let loginId: String
}
