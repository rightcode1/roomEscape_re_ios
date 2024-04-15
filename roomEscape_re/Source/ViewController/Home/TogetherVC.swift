//
//  TogetherVC.swift
//  roomEscape_re
//
//  Created by 이남기 on 2/19/24.
//

import Foundation
import Alamofire
import SwiftyJSON

class TogetherVC:BaseViewController, UITextFieldDelegate {
  
  @IBOutlet var searchTextField: UITextField!{
    didSet{
      searchTextField.delegate = self
    }
  }
  @IBOutlet var searchButton: UIButton!
  @IBOutlet var togetherButton: UIButton!
  
  @IBOutlet var mainTableView: UITableView!
  
  var userList: [UserListInfoData] = []
  
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    if !textField.text!.isEmpty {
      self.searchUser(search: textField.text!)
    }
    return true
  }
  
  
  override func viewWillAppear(_ animated: Bool) {
    mainTableView.delegate = self
    mainTableView.dataSource = self
    navigationController?.navigationBar.isHidden = false
  }
  override func viewDidLoad() {
    searchButton.rx.tap.bind(onNext: { [weak self] _ in
      if ((self?.searchTextField.text?.isEmpty) != nil){
        self?.showToast(message: "닉네임을 입력해주세요.")
        return
      }
      self?.searchUser(search: self?.searchTextField.text ?? "")
      })
      .disposed(by: disposeBag)
    
    togetherButton.rx.tap.bind(onNext: { [weak self] _ in
      if self?.userList.count ?? 0 < 2{
          self?.showToast(message: "최소 2명의 유저를 선택해주세요.")
        return
      }
      let vc = UIStoryboard.init(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "togetherList") as! TogetherListVC
      vc.userIds =  self!.userList.map { "\($0.id)" }.joined(separator: ",")
      self?.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)
  }
  
  func searchUser(search: String) {
    self.showHUD()
    let apiurl = "/v1/user/list"
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiurl)")!
    let requestURL = url.appending("name", value:search)
    
    var request = URLRequest(url: requestURL)
    request.httpMethod = HTTPMethod.get.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    AF.request(request).responseJSON { (response) in
      switch response.result {
      case .success(let value):
        let decoder = JSONDecoder()
        let json = JSON(value)
        let jsonData = try? json.rawData()
        
        print("\(apiurl) request: \(request)")
        print("\(apiurl) responseJson: \(json)")
        if let data = jsonData, let value = try? decoder.decode(UserListResponse.self, from: data) {
          if value.statusCode == 200 {
            if !value.list.isEmpty{
              if self.userList.contains(where: { $0.id == value.list.first?.id }){
                self.showToast(message: "이미 등록된 유저입니다.")
              }else{
                self.userList.append(value.list.first!)
                self.mainTableView.reloadData()
              }
            }else{
              self.showToast(message: "없는 유저입니다.")
            }
            self.searchTextField.text = ""
            self.dismissHUD()
          }
        }
        break
      case .failure:
        print("error: \(response.error!)")
        self.dismissHUD()
        break
      }
    }
  }
  
}
extension TogetherVC: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return userList.count
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = mainTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let dict = userList[indexPath.row]
    
    var level = cell.viewWithTag(1) as! UIImageView
    let deleteButton = cell.viewWithTag(3) as! UIButton
    let nickName = cell.viewWithTag(2) as! UILabel
    let backView = cell.viewWithTag(4) as! UIView
    
    
    level.image = UIImage(named: "BigLevel\(dict.reviewLevel)")
    
    nickName.text = dict.name
    
    backView.layer.cornerRadius = 5
    backView.layer.shadowColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    backView.layer.shadowOpacity = 1
    backView.layer.shadowOffset = CGSize(width: 0, height: 2)
    backView.layer.shadowRadius = 2
    
    deleteButton.rx.tap.bind(onNext: { [weak self] _ in
      self?.userList.removeAll { $0.id == dict.id }
      self?.mainTableView.reloadData()
      })
      .disposed(by: disposeBag)
    return cell
    
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    return 55
  }
  
}
