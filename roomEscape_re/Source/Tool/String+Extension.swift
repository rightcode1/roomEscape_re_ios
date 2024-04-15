//
//  String+Extension.swift
//  FOAV
//
//  Created by hoon Kim on 16/10/2019.
//  Copyright © 2019 hoon Kim. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    func contains(find: String) -> Bool {
        return self.range(of: find) != nil
    }
  
    func containsIgnoringCase(find: String) -> Bool {
        return self.range(of: find, options: .caseInsensitive) != nil
    }
  
    func isPhone() -> Bool {
        let regex = "^01([0|1|6|7|8|9]?)([0-9]{3,4})([0-9]{4})$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
    
    func isIdValidate() -> Bool {
        // 영문 + 숫자 5 ~ 20 자리
        let regex = "^[a-zA-Z0-9]{5,20}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
    func isValidateCode() -> Bool {
      return self.count >= 6
    }
    
    func isPasswordValidate() -> Bool {
        // 영문 + 특수문자 + 숫자 8 ~ 13 자리
        let regex = "^(?=.*[a-zA])(?=.*[0-9])(?=.*[!@#$%^&*])(?=.{8,13})"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
  
  func isCheckEmoji() -> Bool {
    let regex = "^(?=.*[a-zA])(?=.*[0-9])(?=.*[!@#$%^&|:<>~/';\"`.,\\?\\}\\{\\|\\*\\[\\]\\(\\)-_/])(?=.{0,5000})"
    return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
  }
  
  func isValidateEmail() -> Bool {
    let emailRegEx = #"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}"#
    return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: self)
  }
  
  func isCommentValidate() -> Bool {
      // 영문 + 숫자 5 ~ 20 자리
      let regex = "^[a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ!@#$%^&|:<>~/';\"`.,\\?\\}\\{\\|\\*\\[\\]\\(\\)-_/\\s]{0,5000}$"
      return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
  }
  
    var stringToDate:Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: self)!
    }
  
  var hashString: Int {
      let unicodeScalars = self.unicodeScalars.map { $0.value }
      return unicodeScalars.reduce(5381) {
          ($0 << 5) &+ $0 &+ Int($1)
      }
  }
  
  func estimateFrameForText(_ text: String) -> CGRect {
      let size = CGSize(width: 250, height: 1000)
      let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
      return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)], context: nil)
  }
  
  func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
       let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
    let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font : font], context: nil)
   
       return ceil(boundingBox.height)
   }

   func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
       let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
    let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font : font], context: nil)

       return ceil(boundingBox.width)
   }
}

extension Int {
    func formattedProductPrice() -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        guard let formattedCount = formatter.string(from: self as NSNumber) else {
            return nil
        }
        return formattedCount
    }
}
