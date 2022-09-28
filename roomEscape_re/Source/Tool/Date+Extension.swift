//
//  Date+Extension.swift
//  FOAV
//
//  Created by hoon Kim on 13/11/2019.
//  Copyright © 2019 hoon Kim. All rights reserved.
//

import Foundation
import UIKit

extension Date {
  var millisecondsSince1970:Int64 {
    return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    //RESOLVED CRASH HERE
  }
  
  init(milliseconds:Int) {
    self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
  }
  
  var dayBefore: Date {
    return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
  }
  
  var dayAfter: Date {
    return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
  }
  
  var noon: Date {
    return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
  }
  
  var month: Int {
    return Calendar.current.component(.month,  from: self)
  }
  
  var startOfDay: Date {
    return Calendar.current.startOfDay(for: self)
  }
  
  var startOfMonth: Date {
    
    let calendar = Calendar(identifier: .gregorian)
    let components = calendar.dateComponents([.year, .month], from: self)
    
    return  calendar.date(from: components)!
  }
  
  var endOfDay: Date {
    var components = DateComponents()
    components.day = 1
    components.second = -1
    return Calendar.current.date(byAdding: components, to: startOfDay)!
  }
  
  var endOfMonth: Date {
    var components = DateComponents()
    components.month = 1
    components.second = -1
    return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
  }
  
  func isMonday() -> Bool {
    let calendar = Calendar(identifier: .gregorian)
    let components = calendar.dateComponents([.weekday], from: self)
    return components.weekday == 2
  }
  
  func toString(dateFormat format: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: self)
  }
  
  static func - (lhs: Date, rhs: Date) -> TimeInterval {
    return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
  }
  
}
