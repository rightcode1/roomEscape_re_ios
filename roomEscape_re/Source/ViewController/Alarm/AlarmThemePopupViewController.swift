//
//  AlarmThemePopupViewController.swift
//  roomEscape_re
//
//  Created by 이남기 on 4/22/24.
//

import Foundation


import UIKit
import Cosmos
import Alamofire
import SwiftyJSON

protocol ThemeAlarmProtocol{
  func themeAlarm()
}

class AlarmThemePopupViewController: BaseViewController {
  @IBOutlet var themeImageView: UIImageView!
  @IBOutlet var themeNameLabel: UILabel!
  @IBOutlet var themeDiffLabel: UILabel!
  @IBOutlet var themeCompanyLabel: UILabel!
  @IBOutlet var themeCosmosView: CosmosView!
  @IBOutlet var themeRatingLabel: UILabel!
  @IBOutlet var themeWishCount: UILabel!
  
  @IBOutlet var alarmDiff1View: UIView!
  @IBOutlet var alarmDiff2View: UIView!
  @IBOutlet var cancelButton: UIButton!
  @IBOutlet var registButton: UIButton!
  
  var diffList: [String] = []
  var delegate: ThemeAlarmProtocol?
  var theme: ThemaListData?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initrx()
    initUI()
  }
  func initUI(){
    themeImageView.kf.setImage(with: URL(string: theme?.thumbnail ?? ""))
    themeNameLabel.text = theme?.title
    themeDiffLabel.text = theme?.category
    themeCompanyLabel.text = theme?.companyName
    themeCosmosView.rating = theme?.grade ?? 0.0
    themeRatingLabel.text = "\(theme?.grade ?? 0.0)"
    themeWishCount.text = "\(theme?.wishCount ?? 0)"
  }
  
  func initrx(){
    alarmDiff1View.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        if !self!.diffList.contains("양도/교환"){
          self!.diffList.append("양도/교환")
        }else{
          self!.diffList.remove("양도/교환")
        }
        self?.alarmDiff1View.borderColor = self!.diffList.contains("양도/교환") ? #colorLiteral(red: 1, green: 0.69319278, blue: 0, alpha: 1) : #colorLiteral(red: 0.9294117093, green: 0.9294116497, blue: 0.9294117093, alpha: 1)
      })
      .disposed(by: disposeBag)
    
    alarmDiff2View.rx.tapGesture().when(.recognized)
        .bind(onNext: { [weak self] _ in
          if !self!.diffList.contains("일행구하기"){
            self!.diffList.append("일행구하기")
          }else{
              self!.diffList.remove("일행구하기")
          }
          self?.alarmDiff2View.borderColor = self!.diffList.contains("일행구하기") ? #colorLiteral(red: 1, green: 0.69319278, blue: 0, alpha: 1) : #colorLiteral(red: 0.9294117093, green: 0.9294116497, blue: 0.9294117093, alpha: 1)
        })
        .disposed(by: disposeBag)
    
    cancelButton.rx.tapGesture().when(.recognized)
        .bind(onNext: { [weak self] _ in
          self?.backPress()
        })
        .disposed(by: disposeBag)
    
    registButton.rx.tapGesture().when(.recognized)
        .bind(onNext: { [weak self] _ in
          self?.registerThemeAlarm()
        })
        .disposed(by: disposeBag)
  }
  
  func registerThemeAlarm() {
    self.showHUD()
    let apiUrl = "/v1/alert/register"
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiUrl)")!
    var request = URLRequest(url: url)
    request.httpMethod = HTTPMethod.post.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("\(DataHelperTool.token ?? "")", forHTTPHeaderField: "Authorization")
    
    request.httpBody = try! JSONSerialization.data(withJSONObject: [
      "themeId": theme?.id,
      "diff": diffList], options: .prettyPrinted)
    AF.request(request).responseJSON { [self] (response) in
      switch response.result {
      case .success(let value):
        let decoder = JSONDecoder()
        let json = JSON(value)
        let jsonData = try? json.rawData()
        
        print("\(apiUrl) responseJson: \(json)")
        
        if let data = jsonData, let value = try? decoder.decode(DefaultResponse.self, from: data) {
          self.dismissHUD()
          self.delegate?.themeAlarm()
          self.backPress()
        }
        break
      case .failure:
        print("\(apiUrl) error: \(response.error!)")
        self.dismissHUD()
        break
      }
    }
  }
}
