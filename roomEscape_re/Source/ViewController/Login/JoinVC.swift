//
//  JoinViewController.swift
//  ppuryoManager_ios
//
//  Created by hoonKim on 2021/07/05.
//

import UIKit


class JoinVC: BaseViewController {
  
  @IBOutlet weak var idTextField: UITextField!
  
  @IBOutlet weak var pwTextField: UITextField!
  @IBOutlet weak var pwCheckTextField: UITextField!
  
  @IBOutlet weak var phoneNumTextField: UITextField!
  @IBOutlet weak var codeTextField: UITextField!
  
  @IBOutlet weak var ownerNameTextField: UITextField!

 
  
  var isNotExist: Bool = false
  
  var oneTimeCertificate: Bool = false
  
  
  override func viewDidLoad() {
    super.viewDidLoad()

  }
  
  func finishRegistHandler() {
    self.dismissHUD()
    callOkActionMSGDialog(message: "회원가입이 완료되었습니다.") {
      self.backPress()
    }
  }
  
  func checId() {
    if idTextField.text! == "" {
      self.callMSGDialog(message: "아이디를 입력해주세요.")
      return
    }
    
    self.showHUD()
    ApiService.request(router: AuthApi.isExistLoginId(loginId: idTextField.text!), success: { (response: ApiResponse<DefaultCodeResponse>) in
      guard let value = response.value else {
        return
      }
      self.dismissHUD()
      if value.statusCode == 200 {
        self.isNotExist = true
        self.callMSGDialog(message: "사용가능한 아이디입니다.")
      } else {
        self.isNotExist = false
        self.callMSGDialog(message: "사용할 수 없는 아이디입니다.")
      }
    }) { (error) in
      self.dismissHUD()
      self.callMSGDialog(message: "\(error?.errorResponse?.message ?? "")")
    }
  }
  
  func sendOneTimeCode() {
    
    if phoneNumTextField.text! == "" {
      self.callMSGDialog(message: "핸드폰번호를 입력해주세요.")
      return
    }
    
    let param = SendCodeRequest (
      phoneNum: phoneNumTextField.text!, joinOrFind: "join"
    )
    self.showHUD()
    ApiService.request(router: AuthApi.sendCode(param: param), success: { (response: ApiResponse<DefaultResponse>) in
      guard let value = response.value else {
        return
      }
      self.dismissHUD()
      if value.statusCode >= 202 {
        self.callMSGDialog(message: value.message)
      }else {
        self.callMSGDialog(message: "인증번호가 전송되었습니다.")
      }
    }) { (error) in
      self.dismissHUD()
      self.callMSGDialog(message: "\(error?.errorResponse?.message ?? "")")
    }
  }
  
  func checkOneTimeCode() {
    if phoneNumTextField.text! == "" {
      self.callMSGDialog(message: "핸드폰번호를 입력해주세요.")
      return
    }
    if codeTextField.text!.count != 6 {
      callMSGDialog(message: "인증번호는 6자리입니다. 다시 입력해주세요.")
      return
    }
    // 인증번호 확인
    self.showHUD()
    let param = CheckphoneCodeRequest (
      tel: phoneNumTextField.text!, confirm: codeTextField.text!
    )
    ApiService.request(router: AuthApi.confirm(param: param), success: { (response: ApiResponse<DefaultResponse>) in
      guard let value = response.value else {
        return
      }
      self.dismissHUD()
      
      if value.statusCode >= 202 {
        self.callMSGDialog(message: value.message)
      } else {
        self.callMSGDialog(message: "인증이 완료되었습니다.")
        self.oneTimeCertificate = true
      }
    }) { (error) in
      self.dismissHUD()
      self.callMSGDialog(message: "\(error?.errorResponse?.message ?? "")")
    }
  }
  
  func requestJoin() {
    if idTextField.text! == "" {
      self.callMSGDialog(message: "아이디를 입력해주세요.")
      return
    }

    if !isNotExist {
      self.callMSGDialog(message: "아이디 중복확인을 입력해주세요.")
      return
    }

    if pwTextField.text == "" {
      self.callMSGDialog(message: "비밀번호를 입력해주세요.")
      return
    }
    
    if pwCheckTextField.text == "" {
      self.callMSGDialog(message: "비밀번호를 입력해주세요.")
      return
    }
    
    if pwCheckTextField.text != pwTextField.text! {
      self.callMSGDialog(message: "비밀번호를 정확히 입력해주세요.")
      return
    }

    if ownerNameTextField.text! == "" {
      self.callMSGDialog(message: "사업자명을 입력해주세요.")
      return
    }


    if phoneNumTextField.text! == "" {
      self.callMSGDialog(message: "핸드폰번호를 입력해주세요.")
      return
    }
    
    let param = JoinRequest (
      loginId: idTextField.text!,
      password: pwTextField.text!,
      tel: phoneNumTextField.text!,
      name: ownerNameTextField.text!
    )
    
    self.showHUD()
    ApiService.request(router: AuthApi.join(param: param), success: { (response: ApiResponse<JoinResponse>) in
      guard let value = response.value else {
        return
      }
      if value.statusCode >= 202 {
        self.dismissHUD()
        self.callMSGDialog(message: value.message)
      } else {
        self.finishRegistHandler()
      }
    }) { (error) in
      self.dismissHUD()
      self.callMSGDialog(message: "\(error?.errorResponse?.message ?? "")")
    }
  }
  
  @IBAction func tapCheckId(_ sender: UIButton) {
    checId()
  }
  
  @IBAction func tapSendCode(_ sender: UIButton) {
    sendOneTimeCode()
  }
  
  @IBAction func tapCheckCode(_ sender: UIButton) {
    checkOneTimeCode()
  }
  
  @IBAction func tapJoin(_ sender: UIButton) {
    requestJoin()
  }
  
}
