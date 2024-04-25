//
//  SplashViewController.swift
//  camver
//
//  Created by hoonKim on 2021/10/31.
//

import UIKit
import Alamofire
import SwiftyJSON

class SplashVC: BaseViewController {
  
  var version: String? {
    guard let dictionary = Bundle.main.infoDictionary,
          let build = dictionary["CFBundleVersion"] as? String else {return nil}
    return build
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    DataHelper<Int>.set(1, forKey: .adCount)
    self.versionCheck()
  }
  func versionCheck() {
    DispatchQueue.main.async {
      self.showHUD()
    }
    ApiService.request(router: VersionApi.version, success: { [self] (response: ApiResponse<VersionResponse>) in
      guard let value = response.value else {
        return
      }
      if value.statusCode < 202 {
        let themeFilter = ThemeListRequest()
        DataHelper<ThemeListRequest>.setThemeListFilter(themeFilter)
        let versionNumber: Int = Int(self.version!) ?? 0
        print("version : \(versionNumber)", value.data.ios)
        if versionNumber  < value.data.ios {
          self.performSegue(withIdentifier: "update", sender: nil)
        } else {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge], completionHandler: {didAllow,Error in
            if didAllow {
              self.setNotificationToken()
            } else {
              if DataHelperTool.userId != nil && DataHelperTool.userPw != nil && DataHelperTool.playTimeType != nil && DataHelperTool.token != nil && DataHelperTool.userNickname != nil && DataHelperTool.userAppId != nil {
                self.login()
              } else {
                DispatchQueue.main.async {
                  self.moveToLogin()
                }
              }
            }
        })
        }
      }
    }) { (error) in
      DispatchQueue.main.async {
        self.dismissHUD()
      }
    }
  }
  
  func setNotificationToken() {
    let param = NotificationRequest (
      notificationToken: DataHelper<String>.value(forKey: .pushToken) ?? ""
    )
    ApiService.request(router: NotificationApi.registNotificationToken(param: param), success: { [self] (response: ApiResponse<DefaultResponse>) in
      guard let value = response.value else {
        return
      }
      if value.statusCode < 202 {
        if DataHelperTool.userId != nil && DataHelperTool.userPw != nil && DataHelperTool.playTimeType != nil && DataHelperTool.token != nil && DataHelperTool.userNickname != nil && DataHelperTool.userAppId != nil {
          self.login()
        } else {
          self.moveToLogin()
        }
      }
    }) { (error) in
      DispatchQueue.main.async {
        self.dismissHUD()
        if DataHelperTool.userId != nil && DataHelperTool.userPw != nil && DataHelperTool.playTimeType != nil && DataHelperTool.token != nil && DataHelperTool.userNickname != nil && DataHelperTool.userAppId != nil {
          self.login()
        } else {
          self.moveToLogin()
        }
      }
    }
  }
  
  func login() {
    DispatchQueue.main.async {
      self.showHUD()
    }
    ApiService.request(router: AuthApi.login(loginId: DataHelperTool.userId ?? "", password: DataHelperTool.userPw ?? ""), success: { (response: ApiResponse<LoginResponse>) in
      guard let value = response.value else {
        return
      }
      if value.statusCode > 200 {
        DispatchQueue.main.async {
          self.dismissHUD()
        }
        self.moveToLogin()
      }else if value.statusCode == 202{
        DispatchQueue.main.async {
          self.dismissHUD()
        }
        DataHelper.set("bearer \(value.message )", forKey: .token)
        let vc = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "ChangePasswordVC") as! ChangePasswordVC
        self.navigationController?.pushViewController(vc, animated: true)
      } else {
        DataHelper.set("bearer \(value.token ?? "")", forKey: .token)
          self.userInfo { value in
            if value.statusCode > 200{
              DispatchQueue.main.async {
                self.dismissHUD()
              }
              self.moveToLogin()
              return
            }
            var iosPurchaseToken  = ""
            var iosReceiptToken = ""
            iosReceiptToken = self.getReceiptData() ?? ""
            if value.data?.iosPurchaseToken == nil || value.data?.iosPurchaseToken == ""{
              iosPurchaseToken = iosReceiptToken
            }else{
              iosPurchaseToken = value.data?.iosPurchaseToken ?? ""
            }
            
            if iosPurchaseToken == iosReceiptToken{
              iosPurchaseToken = iosReceiptToken
            }
            
            self.subCheck(iosReceipt: iosPurchaseToken) { success in
              DispatchQueue.main.async {
                self.dismissHUD()
              }
              self.goTabBar()
          }
        }
      }
    }) { (error) in
      DispatchQueue.main.async {
        self.dismissHUD()
      }
      self.moveToLogin()
    }
  }
}
