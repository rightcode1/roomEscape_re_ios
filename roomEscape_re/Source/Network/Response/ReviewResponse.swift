//
//  ReviewResponse.swift
//  roomEscape_re
//
//  Created by hoon Kim on 2022/02/03.
//

import Foundation

// MARK: - CompanyReviewResponse
struct CompanyReviewResponse: Codable {
  let statusCode: Int
  let message: String
  let list: [CompanyReview]
}

struct CompanyRowReviewResponse: Codable {
  let statusCode: Int
  let message: String
  let list: CompanyRowReview
}
struct CompanyRowReview: Codable {
  let count: Int
  let rows: [CompanyReview]
}


// MARK: - CompanyReview
struct CompanyReview: Codable {
  let id, userId: Int
  let userName: String
  let userLevel: Int
  let grade: Double
  let contents, createdAt: String
}

enum ReviewLavel: String, Codable {
  case 매우쉬움
  case 쉬움
  case 보통
  case 어려움
  case 매우어려움
}

enum SuccessDiff: String, Codable {
  case 성공
  case 실패
}

// MARK: - ThemeReviewResponse
struct ThemeReviewResponse: Codable {
  let statusCode: Int
  let message: String
  let list: SubResponseReview
}
struct DefualtThemeReviewResponse: Codable {
  let statusCode: Int
  let message: String
  let list: [ThemeReview]
}

struct SubResponseReview: Codable {
  let count: Int
  let rows: [ThemeReview]
}

// MARK: - ThemeReview
struct ThemeReview: Codable {
  let id, themeId, userId, reviewLevel: Int
  let userName, playDate: String
  let grade: Double
  let level: ReviewLavel
  let success: SuccessDiff
  let extraTime, remainingTime: String?
  let userHint: Int?
  let content: String
  let isGrade: Bool
  let isLike: Bool
  let likeCount: Int
  let createdAt: String
  let theme: ReviewTheme?
  let company: ReviewCompany?
  let comments: [comments]?
}


// MARK: - ReviewCompany
struct ReviewCompany: Codable {
  let id: Int
  let reviewCount: Int?
  let isWish: Bool
  let title: String
  let averageRate: Double?
}

// MARK: - ReviewTheme
struct ReviewTheme: Codable {
  let companyName: String
  let id: Int
  let category: String
  let isWish: Bool
  let title: String
  let thumbnail: String?
}
struct comments: Codable {
  let content: String
}
