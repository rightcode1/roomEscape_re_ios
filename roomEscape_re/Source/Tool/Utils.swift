//
//  Utils.swift
//  coffit
//
//  Created by Picturesque on 2022/01/08.
//

import Foundation
import UIKit

func APP_WIDTH() -> CGFloat {
    return UIScreen.main.bounds.size.width
}

func APP_HEIGHT() -> CGFloat {
    return UIScreen.main.bounds.size.height
}

func APP_VERSION() -> String{
    return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
}

func OS_VERSION() -> String{
    return UIDevice.current.systemVersion
}

func DEVICE_MODEL() -> String{
    return UIDevice.current.name
}

func colorFromRGB(_ rgbValue: UInt, alpha : CGFloat = 1.0) -> UIColor {
    return UIColor(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                   green: CGFloat((rgbValue & 0xFF00) >> 8) / 255.0,
                   blue: CGFloat(rgbValue & 0xFF) / 255.0, alpha: alpha)
}

func DEBUG_LOG(_ msg: Any, file: String = #file, function: String = #function, line: Int = #line) {
    #if DEBUG
        let fileName = file.split(separator: "/").last ?? ""
        let funcName = function.split(separator: "(").first ?? ""
        print("[\(fileName)] \(funcName)(\(line)): \(msg)")
    #endif
}


func JSON_CONVERT(object: Any) -> String? {
    guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
        return nil
    }
    return String(data: data, encoding: String.Encoding.utf8)
}




