//
//  UserInfoResponse.swift
//  roomEscape_re
//
//  Created by hoon Kim on 2022/02/04.
//

import Foundation

// MARK: - UserInfoResponse
struct UserInfoResponse: Codable {
  let statusCode: Int
  let message: String
  let data: UserInfoData?
}

// MARK: - UserInfoData
struct UserInfoData: Codable {
  let noHintSuccessRate,successRate:Double
  let id, reviewCount ,successReviewCount,noHintSuccessReviewCount: Int
  let loginId, tel, name, role: String
  let active, isReviewSecret: Bool
}

struct UserListResponse: Codable {
  let statusCode: Int
  let message: String
  let list: [UserListInfoData]
}

// MARK: - UserInfoData
struct UserListInfoData: Codable {
  let id,reviewLevel: Int
  let name: String
}

