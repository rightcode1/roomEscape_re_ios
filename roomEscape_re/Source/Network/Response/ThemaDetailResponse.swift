//
//  ThemaDetailResponse.swift
//  roomEscape_re
//
//  Created by RightCode_IOS on 2021/12/10.
//

import Foundation

struct ThemaDetailResponse: Codable {
  let statusCode: Int
  let message: String
  let data: ThemaDetailData
}

struct ThemaDetailData: Codable {
  let id, companyId: Int
  let companyName, title, intro, category: String
  let companyTel, companyHomepage: String
  let typeOnly, typeDifferent, typeNew, isReview: Bool
  let level, recommendPerson: Int
  let tool, activity: String
  let time: Int
  let grade: Double
  let thumbnail: String?
  let reviewCount, wishCount: Int
  let isWish: Bool
//  let images: [Image]
  let themePrices: [ThemePrice]
}
// 상세 콜렉션
struct Image: Codable {
  let id: Int
  let name: String
}
// 요금 테이블
struct ThemePrice: Codable {
  let id: Int
  let title: String
  let price: Int
}
