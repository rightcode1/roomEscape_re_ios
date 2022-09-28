//
//  AppDelegate.swift
//  roomEscape_re
//
//  Created by hoonKim on 2021/11/14.
//

import UIKit
import IQKeyboardManagerSwift

var isFirstStart: Bool = true

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    Thread.sleep(forTimeInterval: 2.0)
    
    IQKeyboardManager.shared.enable = true
    IQKeyboardManager.shared.enableAutoToolbar = true
    IQKeyboardManager.shared.toolbarTintColor = #colorLiteral(red: 1, green: 0.6352941176, blue: 0, alpha: 1)
    
    if #available(iOS 15.0, *) {
      let appearance = UITabBarAppearance()
      appearance.configureWithOpaqueBackground()
      
      UITabBar.appearance().backgroundColor = UIColor.white
    }
    return true
  }


}

