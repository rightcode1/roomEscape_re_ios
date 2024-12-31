//
//  AppDelegate.swift
//  roomEscape_re
//
//  Created by hoonKim on 2021/11/14.
//

import UIKit
import IQKeyboardManagerSwift
import GoogleMobileAds
import Firebase
import KakaoMapsSDK

var isFirstStart: Bool = true

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    Thread.sleep(forTimeInterval: 2.0)
    
    IQKeyboardManager.shared.enable = true
    IQKeyboardManager.shared.enableAutoToolbar = true
    IQKeyboardManager.shared.toolbarTintColor = #colorLiteral(red: 1, green: 0.6352941176, blue: 0, alpha: 1)
    GADMobileAds.sharedInstance().start(completionHandler: nil)

    
    if #available(iOS 15.0, *) {
      let appearance = UITabBarAppearance()
      appearance.configureWithOpaqueBackground()
      
      UITabBar.appearance().backgroundColor = UIColor.white
    }
    FirebaseApp.configure()
    SDKInitializer.InitSDK(appKey: "8a051509be29c395e615273bebce38ef")
    
    // 앱 실행 시 사용자에게 알림 허용 권한을 받음
    UNUserNotificationCenter.current().delegate = self
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound] // 필요한 알림 권한을 설정
    UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { _, _ in }
    )
    
    // UNUserNotificationCenterDelegate를 구현한 메서드를 실행시킴
    application.registerForRemoteNotifications()
    
    // 파이어베이스 Meesaging 설정
    Messaging.messaging().delegate = self
    return true
  }


}
extension AppDelegate: MessagingDelegate,UNUserNotificationCenterDelegate {
  // Foreground(앱 켜진 상태)에서도 알림 오는 설정
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    if #available(iOS 14.0, *) {
      completionHandler([.list, .banner])
    } else {
      // Fallback on earlier versions
    }
  }
  
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    if let fcmToken = fcmToken {
      print("!!!!!!!!!!!\(fcmToken)")
      let dataDict:[String: String] = ["token": fcmToken]
      DataHelper.set(fcmToken, forKey: .pushToken)
      NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
  }
}


