//
//  AuthRequest.swift
//  ppuryo
//
//  Created by hoonKim on 2021/05/06.
//

import Foundation

struct SocialLoginRequest: Codable {
  let loginId: String
  let password: String?
  let provider: SocialLoginDiff
  let name: String?
}

enum SocialLoginDiff: String, Codable {
  case kakao
  case apple
}

struct JoinRequest: Codable {
  let loginId: String
  let password: String
  let tel: String
  let name: String
}

struct CheckloginId: Codable {
  var loginId: String
}

struct SendCodeRequest: Codable {
  var phoneNum: String
  var joinOrFind: String
  
  enum CodingKeys: String, CodingKey {
    case phoneNum = "tel"
    case joinOrFind = "diff"
  }
}

struct FindMyIdRequest: Codable {
  var tel: String
}

struct CheckphoneCodeRequest: Codable {
  let tel: String
  let confirm: String
}

struct ChangePasswordRequest: Codable {
  var loginId: String
  var password: String
  var tel: String
  
}
struct UserUpdateRequest: Codable {
  var name: String?
  var password: String?
  var isReviewSecret: Bool?
}

struct reviewLikeRequest: Codable {
  var themeReviewId: Int?
}

struct reviewReportRequest: Codable {
  var themeReviewId: Int?
  var companyReviewId: Int?
  var content: String?
}
