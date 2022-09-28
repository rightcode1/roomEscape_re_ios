//
//  ThemaListResponse.swift
//  roomEscape_re
//
//  Created by RightCode_IOS on 2021/12/08.
//

import Foundation

//MARK: - 추천 테마 리스트
struct ThemaListResponse: Codable {
  let statusCode: Int
  let message: String
  let list: SubResponseThema
}

struct ThemeDefaultListResponse: Codable {
  let statusCode: Int
  let message: String
  let list: [ThemaListData]
}

// MARK: - List
struct SubResponseThema: Codable {
  let count: Int
  let rows: [ThemaListData]
}

struct ThemaListData: Codable {
  let id, companyId: Int
  let title, companyName, category: String
  let typeOnly, typeDifferent, typeNew: Bool
  let level, recommendPerson: Int
  let tool, activity: String
  let time: Int
  let grade: Double
  let thumbnail: String?
  let reviewCount: Int
  var wishCount: Int
  var isWish: Bool
}
