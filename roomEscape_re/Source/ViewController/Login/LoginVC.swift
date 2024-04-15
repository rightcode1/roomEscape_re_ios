//
//  LoginViewController.swift
//  ppuryoManager_ios
//
//  Created by hoonKim on 2021/07/05.
//

import UIKit

var needPasswordUpdate: Bool = false

class LoginVC: BaseViewController {
  
  @IBOutlet weak var idTextField: UITextField!
  @IBOutlet weak var pwTextField: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // 네비게이션 바 배경 투명하게 만드는 법
    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    self.navigationController?.navigationBar.clipsToBounds = true
    
  }
  
  func login() {
    if idTextField.text! == "" {
      self.callMSGDialog(message: "아이디를 입력해주세요.")
      return
    }
    
    if pwTextField.text! == "" {
      callMSGDialog(message: "비밀번호를 입력해주세요.")
      return
    }
    self.showHUD()
    ApiService.request(router: AuthApi.login(loginId: idTextField.text!, password: pwTextField.text!), success: { (response: ApiResponse<LoginResponse>) in
      guard let value = response.value else {
        return
      }
      self.dismissHUD()
      if value.statusCode == 200 { // 성공
        DataHelper.set("bearer \(value.token ?? "")", forKey: .token)
        self.userInfo { UserInfoResponse in
          self.setNotificationToken()
          DataHelper.set(self.idTextField.text!, forKey: .userId)
          DataHelper.set(self.pwTextField.text!, forKey: .userPw)
          DataHelper.set("남은시간", forKey: .playTimeType)
          self.goTabBar()
        }
      }else  if value.statusCode == 202 {
        DataHelper.set("bearer \(value.message )", forKey: .token)
        let vc = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "ChangePasswordVC") as! ChangePasswordVC
        self.navigationController?.pushViewController(vc, animated: true)
      } else{ //로그인 실패-
        self.callMSGDialog(message: value.message)
      }
    }) { (error) in
      self.dismissHUD()
      if (error?.statusCode ?? 0) == 401 {
        self.dismissHUD()
        self.callMSGDialog(message: "제한된 사용자 입니다.")
      } else {
        self.callMSGDialog(message: "아이디가 없거나 비밀번호가 일치하지 않습니다.")
      }
    }
  }
  
  func setNotificationToken() {
    self.showHUD()
    let param = NotificationRequest (
      notificationToken: DataHelper<String>.value(forKey: .pushToken) ?? ""
    )
    ApiService.request(router: NotificationApi.registNotificationToken(param: param), success: { [self] (response: ApiResponse<DefaultResponse>) in
      guard let value = response.value else {
        return
      }
      if value.statusCode < 202 {
      }
    }) { (error) in
      self.dismissHUD()
    }
  }
  
  
  @IBAction func tapLogin(_ sender: UIButton) {
    login()
  }
  
}
