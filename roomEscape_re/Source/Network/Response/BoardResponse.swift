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
  case 방탈출정보 = "방탈출정보"
  case 보드판갤러리 = "보드판 갤러리"
  case 일행구하기 = "일행구하기"
  case 자유게시판 = "자유게시판"
}

// MARK: - List
struct BoardList: Codable {
  let id: Int
  let user_pk: String
  let nickname: String
  let grade: String
  let thumbnail, company_name, themeName: String?
  let title: String
  let content: String
  let diff: BoardDiff
  let category: String?
  let commentCount, likeCount: Int
  let isLike, createdAt: String
  let viewCount: Int
}


struct BoardCommentListResponse: Codable {
  let statusCode: Int
  let message: String
  let list: [BoardCommentList]?
}

struct BoardCommentList: Codable {
  let id: Int
  let boardId: Int
  let user_pk: String
  let nickname: String
  let grade: String
  let depth: String
  let content: String
  let createdAt: String
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
