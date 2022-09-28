//
//  BoardRequest.swift
//  room_escape
//
//  Created by hoonKim on 2021/06/13.
//  Copyright © 2021 park. All rights reserved.
//

import Foundation

struct BoardListRequest: Codable {
  let page: Int?
  let limit: Int?
  let diff: BoardDiff?
  let category: String?
  let sort: String?
  let user_pk: Int?
  let search: String?
  
  init(
    page: Int? = nil,
    limit: Int? = nil,
    diff: BoardDiff? = nil,
    category: String? = nil,
    sort: String? = nil,
    user_pk: Int? = nil,
    search: String? = nil
  ) {
    self.page = page
    self.limit = limit
    self.diff = diff
    self.category = category
    self.sort = sort
    self.user_pk = user_pk
    self.search = search
  }
}

struct BoardCommentRegistRequest: Codable {
  let boardId: Int
  let user_pk: String
  let nickname: String
  let grade: String
  let content: String
  let boardCommentId: Int? 
}

struct RegistBoardRequest: Codable {
  let user_pk, nickname, grade: String
  let title: String?
  let content: String
  let diff: BoardDiff
  let company_name, theme_name, category: String?
}

struct ModifyBoardRequest: Codable {
  let title: String?
  let company_name, theme_name: String?
  let content: String?
  let category: String?
}
