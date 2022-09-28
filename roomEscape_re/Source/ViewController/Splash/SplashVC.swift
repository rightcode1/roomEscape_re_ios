//
//  SplashViewController.swift
//  camver
//
//  Created by hoonKim on 2021/10/31.
//

import UIKit

class SplashVC: BaseViewController {
  
  var version: String? {
    guard let dictionary = Bundle.main.infoDictionary,
          let build = dictionary["CFBundleVersion"] as? String else {return nil}
    return build
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
      versionCheck()
    
  }
  func versionCheck() {
    self.showHUD()
    ApiService.request(router: VersionApi.version, success: { [self] (response: ApiResponse<VersionResponse>) in
      guard let value = response.value else {
        return
      }
      if value.statusCode < 202 {
        let themeFilter = ThemeListRequest()
        DataHelper<ThemeListRequest>.setThemeListFilter(themeFilter)
        print("version : \(self.version ?? "000000000")", value.data.ios)
        let versionNumber: Int = Int(self.version!) ?? 0
        print("version : \(versionNumber)", value.data.ios)
        if versionNumber  < value.data.ios {
          self.performSegue(withIdentifier: "update", sender: nil)
        } else {
          if DataHelperTool.userId != nil && DataHelperTool.userPw != nil && DataHelperTool.playTimeType != nil && DataHelperTool.token != nil && DataHelperTool.userNickname != nil && DataHelperTool.userAppId != nil {
            self.login()
          } else {
            self.moveToLogin()
          }
        }
      }
    }) { (error) in
      self.dismissHUD()
    }
  }
  
  func login() {
    self.showHUD()
    ApiService.request(router: AuthApi.login(loginId: DataHelperTool.userId ?? "", password: DataHelperTool.userPw ?? ""), success: { (response: ApiResponse<LoginResponse>) in
      guard let value = response.value else {
        return
      }
      self.dismissHUD()
      if value.statusCode > 200 {
        self.moveToLogin()
      } else {
        DataHelper.set("bearer \(value.token ?? "")", forKey: .token)
          self.userInfo { value in
            self.goTabBar()
          }
      }
    }) { (error) in
      self.dismissHUD()
      self.moveToLogin()
    }
  }
}
