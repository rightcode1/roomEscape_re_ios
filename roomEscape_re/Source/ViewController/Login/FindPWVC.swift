//
//  FindPWViewController.swift
//  ppuryoManager_ios
//
//  Created by hoonKim on 2021/09/29.
//

import UIKit

class FindPWVC: BaseViewController {
  @IBOutlet weak var idTextField: UITextField!
  
  @IBOutlet weak var phoneNumTextField: UITextField!
  @IBOutlet weak var codeTextField: UITextField!
  @IBOutlet var emailCheck: UIButton!
  @IBOutlet var phoneCheck: UIButton!
  @IBOutlet var certifiCheck: UIButton!
  
  
  var isNotExist: Bool = false
  
  var oneTimeCertificate: Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    idTextField.rx.text.orEmpty
      .map({ $0.isValidateEmail() })
      .bind(onNext: { [weak self] b in
        guard let self = self else { return }
        emailCheck.backgroundColor = b ? #colorLiteral(red: 1, green: 0.6134027839, blue: 0, alpha: 1) : #colorLiteral(red: 0.4784423709, green: 0.4784183502, blue: 0.4784329534, alpha: 1)
      })
      .disposed(by: disposeBag)
    
    phoneNumTextField.rx.text.orEmpty
      .map({ $0.isPhone() })
      .bind(onNext: { [weak self] b in
        guard let self = self else { return }
          phoneCheck.backgroundColor = b ? #colorLiteral(red: 1, green: 0.6134027839, blue: 0, alpha: 1) : #colorLiteral(red: 0.4784423709, green: 0.4784183502, blue: 0.4784329534, alpha: 1)
      })
      .disposed(by: disposeBag)
    
    codeTextField.rx.text.orEmpty
      .map({ $0.isValidateCode() })
      .bind(onNext: { [weak self] b in
        guard let self = self else { return }
        certifiCheck.backgroundColor = b ? #colorLiteral(red: 1, green: 0.6134027839, blue: 0, alpha: 1) : #colorLiteral(red: 0.4784423709, green: 0.4784183502, blue: 0.4784329534, alpha: 1)
      })
      .disposed(by: disposeBag)
  }
  
  func checkId() {
    if idTextField.text! == "" {
      self.callMSGDialog(message: "아이디를 입력해주세요.")
      return
    }
    
    self.showHUD()
    ApiService.request(router: AuthApi.isExistLoginId(loginId: idTextField.text!), success: { (response: ApiResponse<DefaultCodeResponse>) in
      guard let value = response.value else {
        self.callMSGDialog(message: "존재하지 않는 아이디입니다.")
        return
      }
      self.dismissHUD()
      if value.statusCode >= 202 {
        self.isNotExist = true
        self.callMSGDialog(message: "존재하는 아이디 입니다.")
      }
    }) { (error) in
      self.dismissHUD()
      self.callMSGDialog(message: "알수없는 오류입니다. 잠시후 다시 시도해주세요.")
    }
  }
  
  func sendOneTimeCode() {
    
    if phoneNumTextField.text! == "" {
      self.callMSGDialog(message: "핸드폰번호를 입력해주세요.")
      return
    }
    
    let param = SendCodeRequest (
      phoneNum: phoneNumTextField.text!, joinOrFind: "find"
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
      self.callMSGDialog(message: "알수없는 오류입니다. 잠시후 다시 시도해주세요.")
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
      self.callMSGDialog(message: "알수없는 오류입니다. 잠시후 다시 시도해주세요.")
    }
  }
  
  
  @IBAction func tapCheckId(_ sender: UIButton) {
    checkId()
  }
  
  @IBAction func tapSendCode(_ sender: UIButton) {
    sendOneTimeCode()
  }
  
  @IBAction func tapCheckCode(_ sender: UIButton) {
    checkOneTimeCode()
  }
  
  @IBAction func tapFindPW(_ sender: UIButton) {
    if idTextField.text! == "" {
      self.callMSGDialog(message: "아이디를 입력해주세요.")
      return
    }
    
    if !isNotExist {
      callMSGDialog(message: "아이디 확인 후 진행해주세요.")
      return
    }
    
    if phoneNumTextField.text! == "" {
      self.callMSGDialog(message: "핸드폰번호를 입력해주세요.")
      return
    }
    if codeTextField.text!.count != 6 {
      callMSGDialog(message: "인증번호는 6자리입니다. 다시 입력해주세요.")
      return
    }
    if !oneTimeCertificate {
      callMSGDialog(message: "핸드폰 인증완료 후 진행해주세요.")
      return
    }
    
    
    let vc = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "findPw2") as! FindPW_2VC
    vc.tel = phoneNumTextField.text!
    vc.loginId = idTextField.text!
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
}
