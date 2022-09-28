//
//  UITextField+Extension.swift
//  albang
//
//  Created by hoon Kim on 27/12/2019.
//  Copyright © 2019 hoon Kim. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
  func setLeftPaddingPoints(_ amount:CGFloat){
    let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
    self.leftView = paddingView
    self.leftViewMode = .always
  }
  func setRightPaddingPoints(_ amount:CGFloat) {
    let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
    self.rightView = paddingView
    self.rightViewMode = .always
  }
  /// UITextField Placeholder setColor (내부의 키값을 Class화 시켜서 작업함)
  /// - Parameter color: UIColor 값
  @objc(setCommonPlaceholderColor:) // 함수인자가 존재시 objc 에서 인식못할때 이렇게 표현가능함.
  func setCommonPlaceholderColor(color:UIColor) {
    let ivar = class_getInstanceVariable(UITextField.self, "_placeholderLabel")!
    let placeholderLabel:UILabel = object_getIvar(self, ivar) as! UILabel
    placeholderLabel.textColor = color
  }
}
