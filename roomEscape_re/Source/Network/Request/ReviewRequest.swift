//
//  ReviewRequest.swift
//  roomEscape_re
//
//  Created by hoon Kim on 2022/02/03.
//

import Foundation

// MARK: - ThemeReviewRequest
struct ThemeReviewRequest: Codable {
  let themeId: Int
  let playDate: String
  let grade: Double
  let level, success, extraTime: String
  let userHint: Int
  let content: String
  let isGrade: Bool
}
