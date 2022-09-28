//
//  UIImage+Extension.swift
//  sircle
//
//  Created by SuHan Kim on 09/11/2017.
//  Copyright © 2017 Sircle. All rights reserved.
//

import Foundation
import UIKit

extension UIImage{
  class var profilePlaceHolder: UIImage{
    return UIImage(named: "placeHolder")!
  }
  class var imagePlaceHolder: UIImage{
    return UIImage(named: "noImage")!
  }
  class var expiredPlaceHolder: UIImage{
    return UIImage(named: "expired")!
  }
  class var wallpaperPlaceHolder: UIImage{
    return UIImage(named: "wallpaperPlaceholder")!
  }
  
  func resize(to size: CGSize) -> UIImage? {
    // Actually do the resizing to the rect using the ImageContext stuff
    let aspect = self.size.width / self.size.height
    var rect = CGRect.zero
    if (size.width / aspect) > size.height{
      let height = size.width / aspect
      rect = CGRect(
        x: 0,
        y: size.height - height,
        width: size.width,
        height: height
      )
    } else {
      let width = size.height * aspect
      rect = CGRect(
        x: size.width - width,
        y: 0,
        width: width,
        height: size.height
      )
    }
    
    UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
    UIGraphicsGetCurrentContext()?.clip(to: CGRect(origin: CGPoint.zero, size: size))
    UIGraphicsGetCurrentContext()?.setFillColor(UIColor.black.cgColor)
    self.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
  }
  
  func resizeToWidth(newWidth: CGFloat) -> UIImage {
    
    let scale = newWidth / self.size.width
    let newHeight = self.size.height * scale
    //      UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
    UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: newHeight), false, 3.0)
    self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
  }
  
  func asBase64() -> String?{
    let data = self.jpegData(compressionQuality: 0.9)
    
    return data?.base64EncodedString()
  }
  
  convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)){
    let rect = CGRect(origin: .zero, size: size)
    
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
    color.setFill()
    UIRectFill(rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    guard let cgImage = image?.cgImage else{ return nil }
    self.init(cgImage: cgImage)
  }
}
