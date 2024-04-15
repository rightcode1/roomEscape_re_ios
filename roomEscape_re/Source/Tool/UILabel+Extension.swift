//
//  UILabel+Extension.swift
//  roomEscape_re
//
//  Created by 이남기 on 4/11/24.
//

import Foundation

extension UILabel{
  func changeTextStyle(changeText: String){
    guard let text = self.text else { return }
    let attributeString = NSMutableAttributedString(string: text)
    attributeString.addAttribute(.foregroundColor, value: UIColor(red: 111, green: 111, blue: 111), range: (text as NSString).range(of: changeText))
    attributeString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 12), range: (text as NSString).range(of: changeText))
    self.attributedText = attributeString
  }
  
  func changeTextBoldStyle(changeText: String,fontSize: CGFloat){
    guard let text = self.text else { return }
    let attributeString = NSMutableAttributedString(string: text)
    attributeString.addAttribute(.foregroundColor, value: UIColor(red: 111, green: 111, blue: 111), range: (text as NSString).range(of: changeText))
    attributeString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: fontSize), range: (text as NSString).range(of: changeText))
    self.attributedText = attributeString
  }
}
