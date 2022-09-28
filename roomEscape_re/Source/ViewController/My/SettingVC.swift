//
//  SettingVC.swift
//  roomEscape_re
//
//  Created by 이남기 on 2022/06/01.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class SettingVC :BaseViewController{
  @IBOutlet weak var nameField: UITextField!
  @IBOutlet var pwdField: UITextField!
  @IBOutlet var levelImageVIew: UIImageView!
  @IBOutlet var nickNameLabel: UILabel!
  @IBOutlet var reviewCountLabel: UILabel!
  @IBOutlet var tapReview: UISwitch!
  
  @IBOutlet var remainView: UIView!
  @IBOutlet var remainLabel: UILabel!
  @IBOutlet var playView: UIView!
  @IBOutlet var playLabel: UILabel!
  
  @IBOutlet var shadowVIew: UIView!
  
  var count = 0
  
  override func viewDidLoad() {
    navigationController?.navigationBar.isHidden = false
    
    remainView.roundCorners([.bottomLeft,.topLeft], radius: 10)
    
    if DataHelperTool.playTimeType == "걸린시간"{
      playView.backgroundColor = #colorLiteral(red: 0.9995952249, green: 0.7689252496, blue: 0.03251596913, alpha: 1)
      playLabel.textColor = .white
      
      remainView.backgroundColor = #colorLiteral(red: 0.9411765933, green: 0.9411765337, blue: 0.9411765337, alpha: 1)
      remainLabel.textColor = .black
    }else{
      remainView.backgroundColor = #colorLiteral(red: 0.9995952249, green: 0.7689252496, blue: 0.03251596913, alpha: 1)
      remainLabel.textColor = .white
      
      playView.backgroundColor = #colorLiteral(red: 0.9411765933, green: 0.9411765337, blue: 0.9411765337, alpha: 1)
      playLabel.textColor = .black
    }
    //
    //    shadowVIew.layer.cornerRadius = 10
    //    shadowVIew.shadowRadius = 3
    
    
    initUI()
    themeReviewList()
  }
  
  func initUI() {
    self.userInfo { value in
      guard let data = value.data else {
        self.levelImageVIew.image = UIImage(named: "noneProfile")
        self.nickNameLabel.text = "로그인이 필요합니다."
        return
      }
      
      self.levelImageVIew.image = UIImage(named: "userLevelImage\(1)")
      self.nickNameLabel.text = data.name
      self.nameField.text = data.name
      self.tapReview.isOn = data.isReviewSecret
      //      self.reviewCountLabel.text = "리뷰 \(data.)"
      
    }
  }
  func themeReviewList() {
    let apiurl = "/v1/themeReview/list"
    
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiurl)")!
    let requestURL = url
      .appending("page", value:"1")
      .appending("limit", value: "1")
      .appending("userId", value: "\(DataHelperTool.userAppId ?? 0)")
    
    var request = URLRequest(url: requestURL)
    request.httpMethod = HTTPMethod.get.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    
    AF.request(request).responseJSON { (response) in
      switch response.result {
      case .success(let value):
        let decoder = JSONDecoder()
        let json = JSON(value)
        let jsonData = try? json.rawData()
        print("\(apiurl) responseJson: \(json)")
        
        if let data = jsonData, let value = try? decoder.decode(ThemeReviewResponse.self, from: data) {
          if value.statusCode == 200 {
            self.count = value.list.count
            self.reviewCountLabel.text = "리뷰 \(value.list.count)개"
            if (value.list.count >= 0 && value.list.count <= 10){
              self.levelImageVIew.image = #imageLiteral(resourceName: "userLevelImage1")
            }else if(value.list.count >= 11 && value.list.count <= 50){
              self.levelImageVIew.image = #imageLiteral(resourceName: "userLevelImage2")
            }else if(value.list.count >= 51 && value.list.count <= 100){
              self.levelImageVIew.image = #imageLiteral(resourceName: "userLevelImage3")
            }else if(value.list.count >= 101 && value.list.count <= 200){
              self.levelImageVIew.image = #imageLiteral(resourceName: "userLevelImage4")
            }else if(value.list.count >= 201 && value.list.count <= 300){
              self.levelImageVIew.image = #imageLiteral(resourceName: "userLevelImage5")
            }else if(value.list.count >= 301 && value.list.count <= 500){
              self.levelImageVIew.image = #imageLiteral(resourceName: "userLevelImage6")
            }else if(value.list.count >= 501 && value.list.count <= 1000){
              self.levelImageVIew.image = #imageLiteral(resourceName: "userLevelImage7")
            }else {
              self.levelImageVIew.image = #imageLiteral(resourceName: "userLevelImage8")
            }
          }
        }
        break
      case .failure:
        print("error: \(response.error!)")
        break
      }
    }
  }
  
  func update(_ check: String) {
    self.showHUD()
    let apiurl = "/v1/user/update"
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiurl)")!
    let requestURL = url
    
    var request = URLRequest(url: requestURL)
    
    
    let param : UserUpdateRequest
    if check == "닉네임"{
      param = UserUpdateRequest(name: nameField.text)
    }else if check == "비밀번호"{
      param = UserUpdateRequest(password: pwdField.text)
    }else{
      param = UserUpdateRequest(isReviewSecret: tapReview.isOn)
    }
    
    request.httpMethod = HTTPMethod.put.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("\(DataHelperTool.token ?? "")", forHTTPHeaderField: "Authorization")
    
    request.httpBody = try! JSONSerialization.data(withJSONObject: param.dictionary ?? [:], options: .prettyPrinted)
    
    AF.request(request).responseJSON { [self] (response) in
      switch response.result {
      case .success(let value):
        let decoder = JSONDecoder()
        let json = JSON(value)
        let jsonData = try? json.rawData()
        
        print("\(apiurl) responseJson: \(json)")
        
        if let data = jsonData, let value = try? decoder.decode(DefaultIDResponse.self, from: data) {
          if value.statusCode == 200 {
            self.callOkActionMSGDialog(message: "수정되었습니다.") {
              dismissHUD()
            }
          }
        }
        break
      case .failure:
        print("\(apiurl) error: \(response.error!)")
        self.dismissHUD()
        break
      }
    }
    self.dismissHUD()
  }
  
  func useOut() {
    self.showHUD()
    ApiService.request(router: UserApi.userOut, success: { (response: ApiResponse<DefaultResponse>) in
      guard let value = response.value else {
        return
      }
      self.dismissHUD()
      if value.statusCode == 200 {
        self.moveToLogin()
      }
    }) { (error) in
      self.dismissHUD()
    }
  }
  @IBAction func reviewOnOff(_ sender: UISwitch) {
    update("알림")
  }
  
  @IBAction func tapPlay(_ sender: Any) {
    playView.backgroundColor = #colorLiteral(red: 0.9995952249, green: 0.7689252496, blue: 0.03251596913, alpha: 1)
    playLabel.textColor = .white
    
    remainView.backgroundColor = #colorLiteral(red: 0.9411765933, green: 0.9411765337, blue: 0.9411765337, alpha: 1)
    remainLabel.textColor = .black
    DataHelper.set("걸린시간", forKey: .playTimeType)
  }
  
  @IBAction func tapRemain(_ sender: Any) {
    remainView.backgroundColor = #colorLiteral(red: 0.9995952249, green: 0.7689252496, blue: 0.03251596913, alpha: 1)
    remainLabel.textColor = .white
    
    playView.backgroundColor = #colorLiteral(red: 0.9411765933, green: 0.9411765337, blue: 0.9411765337, alpha: 1)
    playLabel.textColor = .black
    DataHelper.set("남은시간", forKey: .playTimeType)
  }
  
  @IBAction func tapName(_ sender: Any) {
    update("닉네임")
  }
  
  @IBAction func tapPwd(_ sender: Any) {
    update("비밀번호")
  }
  
  @IBAction func tapLevel(_ sender: Any) {
    let vc = UIStoryboard.init(name: "My", bundle: nil).instantiateViewController(withIdentifier: "LevelMenuVC") as! LevelMenuVC
    vc.reviewCount = count
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  @IBAction func tapLogout(_ sender: Any) {
    self.callYesNoMSGDialog(message:"로그아웃 하시겠습니까?") {
      DataHelper<String>.remove(forKey: .userNickname)
      DataHelper<String>.remove(forKey: .userId)
      DataHelper<String>.remove(forKey: .userPw)
      DataHelper<String>.remove(forKey: .userAppId)
      DataHelper<String>.remove(forKey: .token)
      self.moveToLogin()
      
    }
    
  }
  
  @IBAction func tapUserOut(_ sender: Any) {
    self.callYesNoMSGDialog(message:"회원탈퇴 하시겠습니까?") {
      DataHelper<String>.remove(forKey: .userId)
      DataHelper<String>.remove(forKey: .userPw)
      DataHelper<String>.remove(forKey: .userNickname)
      DataHelper<String>.remove(forKey: .userAppId)
      DataHelper<String>.remove(forKey: .token)
      self.useOut()
    }
  }
  
}
