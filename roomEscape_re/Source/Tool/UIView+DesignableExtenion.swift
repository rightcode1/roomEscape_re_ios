//
//  File.swift
//  hangun
//
//  Created by jason on 2018. 6. 22..
//  Copyright © 2018년 jason. All rights reserved.
//

import Foundation
import UIKit


extension UIView {
  
  @IBInspectable
  var cornerRadius: CGFloat {
    get {
      return layer.cornerRadius
    }
    set {
      layer.cornerRadius = newValue
      layer.masksToBounds = newValue > 0
    }
  }
  
  @IBInspectable
  var borderWidth: CGFloat {
    get {
      return layer.borderWidth
    }
    set {
      layer.borderWidth = newValue
    }
  }
  
  @IBInspectable
  var borderColor: UIColor? {
    get {
      let color = UIColor.init(cgColor: layer.borderColor!)
      return color
    }
    set {
      layer.borderColor = newValue?.cgColor
    }
  }
  
  @IBInspectable
  var shadowRadius: CGFloat {
    get {
      return layer.shadowRadius
    }
    set {
      layer.shadowColor = UIColor.black.cgColor
      layer.shadowOffset = CGSize(width: 0, height: 2)
      layer.shadowOpacity = 0.4
      layer.shadowRadius = newValue
    }
  }
}

//
// View for UILabel Accessory
//
extension UIView {
  
  func rightValidAccessoryView() -> UIView {
    let imgView = UIImageView(image: UIImage(named: "check_valid"))
    imgView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
    imgView.backgroundColor = UIColor.clear
    return imgView
  }
  
  func rightInValidAccessoryView() -> UIView {
    let imgView = UIImageView(image: UIImage(named: "check_invalid"))
    imgView.frame = CGRect(x: self.cornerRadius, y: self.cornerRadius, width: 20, height: 20)
    imgView.backgroundColor = UIColor.clear
    return imgView
  }
}

extension CALayer {
  func applySketchShadow(
    color: UIColor = .black,
    alpha: Float = 0.15,
    x: CGFloat = 0,
    y: CGFloat = 0,
    blur: CGFloat = 15,
    spread: CGFloat = 0)
  {
    shadowColor = color.cgColor
    shadowOpacity = alpha
    shadowOffset = CGSize(width: x, height: y)
    shadowRadius = blur / 2.0
    if spread == 0 {
      shadowPath = nil
    } else {
      let dx = -spread
      let rect = bounds.insetBy(dx: dx, dy: dx)
      shadowPath = UIBezierPath(rect: rect).cgPath
    }
  }
  
  func dismissSketchShadow(
    color: UIColor = .white,
    alpha: Float = 0,
    x: CGFloat = 0,
    y: CGFloat = 0,
    blur: CGFloat = 0,
    spread: CGFloat = 0)
  {
    shadowColor = color.cgColor
    shadowOpacity = alpha
    shadowOffset = CGSize(width: x, height: y)
    shadowRadius = 0
    if spread == 0 {
      shadowPath = nil
    } else {
      let dx = -spread
      let rect = bounds.insetBy(dx: dx, dy: dx)
      shadowPath = UIBezierPath(rect: rect).cgPath
    }
  }
}

