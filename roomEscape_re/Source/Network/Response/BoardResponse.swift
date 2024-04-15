//
//  BoardResponse.swift
//  room_escape
//
//  Created by hoonKim on 2021/06/13.
//  Copyright © 2021 park. All rights reserved.
//

import Foundation

struct BoardListResponse: Codable {
  let statusCode: Int
  let message: String
  let list: BoardRows
}
struct BoardRows: Codable {
    let count: Int
  let rows: [BoardList]
}


enum BoardDiff: String, Codable {
  case 양도교환 = "양도/교환"
  case 방탈출정보 = "방탈출정보"
  case 보드판갤러리 = "보드판 갤러리"
  case 일행구하기 = "일행구하기"
  case 자유게시판 = "자유게시판"
}
enum BoardCategory: String, Codable {
  case 공지 = "공지"
  case 정보 = "정보"
  case 소식 = "소식"
  case 이벤트 = "이벤트"
  case 후기 = "후기"
  case 모집중 = "모집중"
  case 모집완료 = "모집완료"
  case 진행 = "진행"
  case 마감 = "마감"
  case 최신순 = "최신순"
  case 추천순 = "추천순"
}

// MARK: - List
struct BoardList: Codable {
  let id: Int
  let nickname,user_pk: String
  let grade: String
  let thumbnail, company_name, themeName: String?
  let title: String
  let content: String
  let diff: BoardDiff
  let category: String?
  let commentCount, likeCount: Int
  let isLike, createdAt: String
  let theme: Thema?
}


struct BoardCommentListResponse: Codable {
  let statusCode: Int
  let message: String
  let list: [BoardCommentList]?
}

struct BoardCommentList: Codable {
  let id: Int
  let boardsId: Int
  let user_pk: String
  let nickname: String
  let grade: String
  let depth: String
  let content: String
  let createdAt: String
  let deletedAt: String?
}

// MARK: - BoardDetailResponse
struct BoardDetailResponse: Codable {
  let statusCode: Int
  let message: String
  let data: BoardDetail
}

// MARK: - DataClass
struct BoardDetail: Codable {
  let id: Int
  let user_pk, nickname, grade, title: String
  let content: String
  let company_name, theme_name: String?
  let diff: BoardDiff
  let category: String?
  let commentCount, likeCount: Int
  let isLike, createdAt: String
  let boardImages: [BoardImage]
  let viewCount: Int
  let theme: Thema?
}

// MARK: - BoardImage
struct BoardImage: Codable {
  let id: Int
  let name: String
}


struct NoticeBoardListResponse: Codable {
  let statusCode: Int
  let message: String
  let list: [NoticeBoard]
}

struct NoticeBoard: Codable {
  let id: Int
  let title: String
  let content: String
}

struct GraduationListResponse: Codable {
  let statusCode: Int
  let message: String
  let list: [Graduation]
}


struct Graduation: Codable {
  let area: String
 let area1: String
  let successCount,themeCount: Int
  let successPer: Double
}

struct StatisticsResponse: Codable {
  let statusCode: Int
  let message: String
  let data: Statistics
}

struct Statistics: Codable {
  let totalCompanyCount: Int
  let totalThemeCount: Int
  let totalReviewCount: Int
  let overlappingThemeCount: Int
  let reviewedOverlapCompanyCount: Int
  let totalOverlapThemeReviewCount: Int
}

// MARK: - ReviewTheme
struct Thema: Codable {
  let companyName: String
  let id: Int
  let category: String
  let isWish: Bool
  let title: String
  let thumbnail: String?
  let grade: Double
  let wishCount: Int
}
