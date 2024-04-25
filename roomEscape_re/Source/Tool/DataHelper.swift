//
//  DataHelper.swift
//  OPenPal
//
//  Created by jason on 11/10/2018.
//  Copyright © 2018 WePlanet. All rights reserved.
//

import Foundation
//import FirebaseMessaging

class DataHelper<T> {
  
  enum DataKeys: String {
    case userId = "userId"
    case userPw = "userPw"
    case token = "token"
    case reportList = "reportList"
    case reportUserList = "reportUserList"
    case userNickname = "userNickname"
    case userAppId = "userAppId"
    case adCount = "adCount"
    case popupDate = "popupDate"
    case isSawGuide = "isSawGuide"
    case newOrderCount = "totalOrderCount"
    case playTimeType = "playTimeType"
    case themeListFilter = "themeListFilter"
    case pushToken = "pushToken"
    case isSub = "isSub"
  }
  
  class func value(forKey key: DataKeys) -> T? {
    if let data = UserDefaults.standard.value(forKey: key.rawValue) as? T {
      return data
    }else {
      return nil
    }
  }
  
  class func appendReportList(_ value: Int) {
    var temp = DataHelperTool.reportList
    temp.insert(value, at: 0)
    let data = try! JSONEncoder().encode(temp)
    UserDefaults.standard.set(data, forKey: DataKeys.reportList.rawValue)
  }
  class func appendReportUserList(_ value: String) {
    var temp = DataHelperTool.reportUserList
    temp.insert(value, at: 0)
    let data = try! JSONEncoder().encode(temp)
    UserDefaults.standard.set(data, forKey: DataKeys.reportUserList.rawValue)
  }
  class func appendAdCount(){
    var count = (DataHelper<Int>.value(forKey: .adCount) ?? 1) + 1
    UserDefaults.standard.set(count, forKey : DataKeys.adCount.rawValue)
  }
  
  class func setThemeListFilter(_ value: ThemeListRequest) {
    let data = try! JSONEncoder().encode(value)
    UserDefaults.standard.set(data, forKey: DataKeys.themeListFilter.rawValue)
  }
  
  
  class func set(_ value:T, forKey key: DataKeys){
    UserDefaults.standard.set(value, forKey : key.rawValue)
  }
  
  class func remove(forKey key: DataKeys) {
    UserDefaults.standard.removeObject(forKey: key.rawValue)
  }
  
  class func clearAll(){
    UserDefaults.standard.dictionaryRepresentation().keys.forEach{ key in
      UserDefaults.standard.removeObject(forKey: key.description)
    }
  }
}

class DataHelperTool {
  
  static var reportList: [Int] {
    guard let IntListData = DataHelper<Data>.value(forKey: .reportList) else { return [] }
    let reportList = try! JSONDecoder().decode([Int].self, from: IntListData)
    return reportList
  }
  static var reportUserList: [String] {
    guard let IntListData = DataHelper<Data>.value(forKey: .reportUserList) else { return [] }
    let reportUserList = try! JSONDecoder().decode([String].self, from: IntListData)
    return reportUserList
  }
  static var userId: String? {
    guard let userId = DataHelper<String>.value(forKey: .userId) else { return nil }
    return userId
  }
  
  static var userPw: String? {
    guard let userPw = DataHelper<String>.value(forKey: .userPw) else { return nil }
    return userPw
  }
  
  static var playTimeType: String? {
    guard let playTimeType = DataHelper<String>.value(forKey: .playTimeType) else { return nil }
    return playTimeType
  }
  
  static var userAppId: Int? {
    guard let userAppId = DataHelper<Int>.value(forKey: .userAppId) else { return nil }
    return userAppId
  }
  static var adCount: Int? {
    guard let adCount = DataHelper<Int>.value(forKey: .adCount) else { return nil }
    return adCount
  }
  
  static var userNickname: String? {
    guard let userNickname = DataHelper<String>.value(forKey: .userNickname) else { return nil }
    return userNickname
  }
  
  static var token: String? {
    guard let token = DataHelper<String>.value(forKey: .token) else { return nil }
    return token
  }
  
  static var popupDate: String? {
    guard let popupDate = DataHelper<String>.value(forKey: .popupDate) else { return nil }
    return popupDate
  }
  
  static var isSawGuide: Bool? {
    guard let isSawGuide = DataHelper<Bool>.value(forKey: .isSawGuide) else { return nil }
    return isSawGuide
  }
  
  static var newOrderCount: Int? {
    guard let newOrderCount = DataHelper<Int>.value(forKey: .newOrderCount) else { return nil }
    return newOrderCount
  }
  static var pushToken: String?{
      guard let pushToken = DataHelper<String>.value(forKey: .pushToken) else { return nil }
      return pushToken
  }
  static var isSub: Bool? {
    guard let isSub = DataHelper<Bool>.value(forKey: .isSub) else { return nil }
    return isSub
  }

  
  static var themeListFilter: ThemeListRequest? {
    guard let themeListFilterData = DataHelper<Data>.value(forKey: .themeListFilter) else { return nil }
    let themeListFilter = try! JSONDecoder().decode(ThemeListRequest.self, from: themeListFilterData)
    return themeListFilter
  }
  
}
  
