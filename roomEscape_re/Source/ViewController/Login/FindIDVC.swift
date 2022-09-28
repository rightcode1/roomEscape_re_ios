//
//  FindIDViewController.swift
//  ppuryoManager_ios
//
//  Created by hoonKim on 2021/09/29.
//

import UIKit
import Alamofire
import SwiftyJSON

class FindIDVC: UIViewController {
  
  @IBOutlet weak var phoneNumTextField: UITextField!
  @IBOutlet weak var codeTextField: UITextField!
  
  var oneTimeCertificate: Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
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
  
  func getId() {
    self.showHUD()
    let url = "\(ApiEnvironment.baseUrl)/v1/auth/findLoginId?tel=\(phoneNumTextField.text!)"
    var request = URLRequest(url: URL(string: url)!)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("\(DataHelperTool.token ?? "")", forHTTPHeaderField: "Authorization")
//    request.httpBody = try! JSONSerialization.data([], options: .prettyPrinted)
    
    AF.request(request).responseJSON { (response) in
      switch response.result {
        case .success(let value):
          let decoder = JSONDecoder()
          let json = JSON(value)
          let jsonData = try? json.rawData()
          print("responseJson: \(json)")
      
          if let data = jsonData, let value = try? decoder.decode(FindIdResponse.self, from: data) {
            switch value.statusCode {
              case 200...201:
                let vc = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "findId2") as! FindID_2VC
                vc.id = value.data?.loginId
                self.navigationController?.pushViewController(vc, animated: true)
              case 202...500:
                self.dismissHUD()
                self.callMSGDialog(message: value.message)
              default:
                self.dismissHUD()
                print(value.message)
            }
          }
          break
        case .failure:
          self.dismissHUD()
          self.callMSGDialog(message: "알수없는 오류입니다. 잠시후 다시 시도해주세요.")
          break
      }
    }
  }
  
  @IBAction func tapSendCode(_ sender: UIButton) {
    sendOneTimeCode()
  }
  
  @IBAction func tapCheckCode(_ sender: UIButton) {
    checkOneTimeCode()
  }
  
  @IBAction func tapFindId(_ sender: UIButton) {
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
    
    
    getId()
  }
  
}
