//
//  ChangePasswordVC.swift
//  roomEscape_re
//
//  Created by hoon Kim on 2022/03/16.
//

import UIKit
import Alamofire
import SwiftyJSON

class ChangePasswordVC: BaseViewController {
  
  @IBOutlet weak var pwTextField: UITextField!
  @IBOutlet weak var pwCheckTextField: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
  }
  
  func changePW() {
    self.showHUD()
    let url = "\(ApiEnvironment.baseUrl)/v1/user/update"
    var request = URLRequest(url: URL(string: url)!)
    request.httpMethod = http_method.put.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("\(DataHelperTool.token ?? "")", forHTTPHeaderField: "Authorization")
    request.httpBody = try! JSONSerialization.data(withJSONObject: [
      "password": pwTextField.text!
    ], options: .prettyPrinted)
    
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
              DataHelper.set(self.pwTextField.text!, forKey: .userPw)
              self.userInfo { value in
                self.goTabBar()
              }
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
  
  @IBAction func tapNext(_ sender: UIButton) {
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
    
    changePW()
  }
}
