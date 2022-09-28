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
    // 인증번호 확인
    self.showHUD()
    ApiService.request(router: AuthApi.login(loginId: idTextField.text!, password: pwTextField.text!), success: { (response: ApiResponse<LoginResponse>) in
      guard let value = response.value else {
        return
      }
      self.dismissHUD()
      if value.statusCode > 202 {
        self.callMSGDialog(message: value.message)
      } else {
        DataHelper.set(self.idTextField.text!, forKey: .userId)
        DataHelper.set("남은시간", forKey: .playTimeType)
        
        self.userInfo { UserInfoResponse in
          if value.statusCode == 202 {
            DataHelper.set("bearer \(value.token ?? "")", forKey: .token)
            let vc = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "ChangePasswordVC") as! ChangePasswordVC
            self.navigationController?.pushViewController(vc, animated: true)
            
          } else {
            DataHelper.set("bearer \(value.token ?? "")", forKey: .token)
            DataHelper.set(self.pwTextField.text!, forKey: .userPw)
            self.userInfo { value in
              self.goTabBar()
            }
          }
        }
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
  
  
  @IBAction func tapLogin(_ sender: UIButton) {
    login()
  }
  
}
