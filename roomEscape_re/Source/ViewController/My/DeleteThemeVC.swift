//
//  DeleteThemeVC.swift
//  roomEscape_re
//
//  Created by 이남기 on 2022/10/17.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class DeleteThemeVC: BaseViewController, WishDelegate, UITextFieldDelegate {
  @IBOutlet var searchTextField: UITextField!{
    didSet{
      searchTextField.delegate = self
    }
  }
  @IBOutlet weak var nothingImageView: UIImageView!
  @IBOutlet weak var tableView: UITableView!
  
  var themeList: [ThemaListData] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.delegate = self
    tableView.dataSource = self
    
    initNothingImageView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.navigationBar.isHidden = true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    if !textField.text!.isEmpty {
      initThemeList(textField.text)
    }
    return true
  }
  
  func initNothingImageView() {
    tableView.isHidden = themeList.count <= 0
    nothingImageView.isHidden = themeList.count > 0
  }
  func initThemeList(_ searchKeyword: String?) {
    showHUD()
    let apiurl = "/v1/theme/list"
    
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiurl)")!
    let requestURL = url
      .appending("search", value: searchKeyword ?? nil)
      .appending("active", value: "false")
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
        
        if let data = jsonData, let value = try? decoder.decode(ThemeDefaultListResponse.self, from: data) {
          if value.statusCode == 200 {
            self.themeList = value.list
            self.tableView.reloadData()
            self.initNothingImageView()
            self.dismissHUD()
          }
        }
        break
      case .failure:
        
        print("error: \(response.error!)")
        break
      }
    }
  }
  
  @IBAction func tapSearch(_ sender: UIButton) {
    if !searchTextField.text!.isEmpty {
      initThemeList(searchTextField.text)
    }
  }
  
  func reloadRows(index: Int) {
    let indexPath = IndexPath(row: index, section: 0)
    tableView.reloadRows(at: [indexPath], with: .automatic)
  }
  
  func didWishButtonTapped(_ index: Int) {
    let dict = themeList[index]
    
    let isWish = dict.isWish ? false : true
    themeWish(dict.id, isWish) { value in
      if value.statusCode <= 201 {
        self.themeList[index].isWish = isWish
        self.themeList[index].wishCount = (isWish ? self.themeList[index].wishCount + 1 : self.themeList[index].wishCount - 1)
        self.reloadRows(index: index)
      }
    }
  }
  
}

extension DeleteThemeVC: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {themeList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.tableView.dequeueReusableCell(withIdentifier: "contentTableViewCell", for: indexPath) as! ContentCell
    let dict = themeList[indexPath.row]
    cell.initContentList(dict)
    cell.delegate = self
    cell.index = indexPath.row
    cell.selectionStyle = .none
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let dict = themeList[indexPath.row]
    
    let vc = UIStoryboard.init(name: "Thema", bundle: nil).instantiateViewController(withIdentifier: "DetailThemaVC") as! DetailThemaVC
    vc.id = dict.id
    self.goViewController(vc: vc)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    return 210
  }
  
}
