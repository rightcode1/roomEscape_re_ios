//
//  Class+DateList.swift
//  newMeetDa
//
//  Created by hoonKim on 2020/06/19.
//  Copyright © 2020 hoonKim. All rights reserved.
//

import Foundation

class DateList {
  let calendar = Calendar.current
  let currentDate = Date()

  var dateformmater = DateFormatter()
  var dateComponent = DateComponents()

  
  var dayCountStringArray: [String] = []
  var monthCountStringArray: [String] = []

  var presentYear: String?
  var presentMonth: String?
  var presentDay: String?
  
  // MARK: - 현재 날짜들 넣어주기
  func getPresentDay() -> String {
    dateformmater.dateFormat = "dd"
    presentDay = dateformmater.string(from: currentDate)
    return dateformmater.string(from: currentDate)
  }
  
  func getPresentMonth() -> String {
    dateformmater.dateFormat = "MM"
    presentMonth = dateformmater.string(from: currentDate)
    return dateformmater.string(from: currentDate)
  }
  
  func getPresentYear() -> String {
    dateformmater.dateFormat = "yyyy"
    presentYear = dateformmater.string(from: currentDate)
    return dateformmater.string(from: currentDate)
  }
  
  func getYearList() -> [String] {
    var yearCountStringArray: [String] = []
    
    dateformmater.dateFormat = "yyyy"
    presentYear = dateformmater.string(from: currentDate)
    // MARK: - 년 배열 추가해주기
    // 배열 넣기전 안에 있는 데이터 제거
    yearCountStringArray.removeAll()
    // 현재 연도 배열에 넣어주기
    yearCountStringArray.append(presentYear!)

    for i in 0 ..< 10 {
      if presentYear != nil {
        dateComponent.year = i + 1
        let futureDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
        yearCountStringArray.append(dateformmater.string(from: futureDate!))
      }
    }
    return yearCountStringArray
  }
  
  func getMonthList(year: String) -> [String] {
    let yearInterval = calendar.dateInterval(of: .year, for: currentDate)

    let month = calendar.dateComponents([.month], from: yearInterval!.start, to: yearInterval!.end)

    let monthCount = month.month

    // 배열 넣기전 안에 있는 데이터 제거
    monthCountStringArray.removeAll()
    // MARK: - 월 배열 추가해주기
    for i in 0..<monthCount! {
      monthCountStringArray.append("\(i + 1)")
    }
    
    if presentYear == year {
      dateformmater.dateFormat = "MM"
      presentMonth = dateformmater.string(from: currentDate)
      
      var removeIndex: Int = 0
      
      for i in 0 ..< monthCountStringArray.count {
        if Int(monthCountStringArray[i])! < Int(presentMonth!) ?? 0 {
          removeIndex = i
        }
      }
      // 현재 연도 일때 지난 월 제거해주기
      for _ in 0 ... removeIndex {
        monthCountStringArray.remove(at: 0)
      }
    }
    return monthCountStringArray
  }
  
  func getDayList(year: String, month: String) -> [String] {
    let selectDate = "\(year)-\(month)"
    dateformmater.dateFormat = "yyyy-MM"
    
    let monthInterval = calendar.dateInterval(of: .month, for: dateformmater.date(from: selectDate)!)

    let day = calendar.dateComponents([.day], from: monthInterval!.start, to: monthInterval!.end)
    
    let dayCount = day.day
    
    dayCountStringArray.removeAll()
    // MARK: - 일 배열 추가해주기
    
    for i in 0..<dayCount! {
      dayCountStringArray.append("\(i + 1)")
    }
    
    if presentYear == year && Int(presentMonth!) == Int(month) {
      print("inininininininininin")
      dateformmater.dateFormat = "dd"
      presentDay = dateformmater.string(from: currentDate)

      var removeIndex_day: Int = 0

      for i in 0 ..< dayCountStringArray.count {
        if Int(dayCountStringArray[i])! < Int(presentDay ?? "") ?? 0 {
          removeIndex_day = i
        }
      }

      // 현재 월 일때 지난 월 제거해주기
      for _ in 0 ... removeIndex_day {
        dayCountStringArray.remove(at: 0)
      }
    }
    return dayCountStringArray
  }

}

