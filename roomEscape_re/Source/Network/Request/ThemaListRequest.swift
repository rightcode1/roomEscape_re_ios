//
//  ThemaListRequest.swift
//  roomEscape_re
//
//  Created by RightCode_IOS on 2021/12/08.
//

import Foundation

struct RequestRecommendationThema: Codable {
  let page: Int
  let limit: Int
}

// 이유: 변수명이 확정적일 경우, 실수를 줄이기 위해 enum Type 사용 권장
enum AreaList: String, Codable {
  case 전국
  case 서울
  case 경기
  case 인천
  case 충청
  case 경상
  case 전라
  case 강원
  case 제주
  
  // 해당 배열 return 해주기 위해 사용
  func getAddressList() -> [String] {
    if self == .서울 {
      return ["전체", "강남", "홍대", "신촌", "건대", "대학로", "강북", "신림", "기타"]
    } else if self == .경기 {
      return ["전체", "부천", "일산", "수원", "안양", "기타"]
    } else if self == .충청 {
      return ["전체", "대전", "천안", "청주", "기타"]
    } else if self == .경상 {
      return ["전체", "대구", "부산", "기타"]
    } else if self == .전라 {
      return ["전체", "전주", "광주", "기타"]
    } else {
      // 위의 해당값이 아니라면 그냥 빈배열 return
      return []
    }
  }
}

enum GenreList: String, Codable {
  case entire = "전체"
  case horror = "공포"
  case adult = "19금"
  case whodunnit = "추리"
  case action = "액션"
  case mellow = "감성"
  case adventure = "모험"
  case sfFantasy = "SF/판타지"
  case outdoor = "야외"
}

enum ThemeSort: String, Codable {
  case 전방추천순 = "전방추천순"
  case 거리순 = "거리순"
}

enum ThemeType: String, Codable {
  case 전체 = "전체"
  case 신규테마 = "신규테마"
  case 이색컨텐츠 = "이색컨텐츠"
  case 혼방가능 = "혼방가능"
}

enum ThemeRate: String, Codable {
  case 전체 = "전체"
  case 점대1 = "1점대"
  case 점대2 = "2점대"
  case 점대3 = "3점대"
  case 점대4 = "4점대"
}

enum ThemeLevel: String, Codable {
  case 전체 = "전체"
  case one = "1"
  case two = "2"
  case three = "3"
  case four = "4"
  case five = "5"
    
  var level: Int {
      switch self {
      case .전체:
        return 0
      case .one:
        return 1
      case .two:
        return 2
      case .three:
        return 3
      case .four:
        return 4
      case .five:
        return 5
  }
  }
}

enum ThemePersonCount: String, Codable {
  case 전체 = "전체"
  case two = "2인"
  case three = "3인"
  case four = "4인"
  case five = "5인 이상"
  
  func personCount() -> Int {
    switch self {
    case .전체:
      return 0
    case .two:
      return 2
    case .three:
      return 3
    case .four:
      return 4
    case .five:
      return 5
    }
  }
}

enum ThemeTool: String, Codable {
  case 전체 = "전체"
  case 높음 = "높음"
  case 보통 = "보통"
  case 낮음 = "낮음"
}
struct ThemeFilterRequest: Codable{
  var sort: String?
  var type: String?
  var rate: String?
  var level: String?
  var person: String?
  var tool: String?
  var activity: String?
  var isMyReview: Bool?
  
}
struct ThemeListRequest: Codable {
  var sort: ThemeSort?
  var type: [ThemeType]
  var rate: [ThemeRate]
var level: [ThemeLevel]
  var person: [ThemePersonCount]
  var tool: [ThemeTool]
  var activity: [ThemeTool]
  var isMyReview: Bool?
  
  init(
    sort: ThemeSort? = .전방추천순,
    type: [ThemeType] = [.전체],
    rate: [ThemeRate] = [.전체],
    level: [ThemeLevel] = [.전체],
    person: [ThemePersonCount] = [.전체],
    tool: [ThemeTool] = [.전체],
    activity: [ThemeTool] = [.전체],
    isMyReview: Bool? = false
  ) {
    self.sort = sort
    self.type = type
    self.rate = rate
    self.level = level
    self.person = person
    self.tool = tool
    self.activity = activity
    self.isMyReview = isMyReview
  }
}
