//
//  UIView+Extension.swift
//  albang
//
//  Created by hoon Kim on 27/12/2019.
//  Copyright © 2019 hoon Kim. All rights reserved.
//

import UIKit
import Foundation

extension UIView {
  func roundCorners(corners: UIRectCorner , radius: CGFloat) {
    let path = UIBezierPath(roundedRect: self.bounds,
                            byRoundingCorners: corners,
                            cornerRadii: CGSize(width: radius, height: radius))
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    self.layer.mask = mask
  }
}
