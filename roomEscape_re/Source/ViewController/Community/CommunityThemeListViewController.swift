//
//  CommunityThemeListViewController.swift
//  roomEscape_re
//
//  Created by 이남기 on 4/8/24.
//

import Foundation
import Cosmos
import Alamofire
import SwiftyJSON

protocol TapTheme{
  func tapDetail(themeId: Int,themeName:String ,themeCompany:String)
}

class CommunityThemeListViewController: BaseViewController{
  
  @IBOutlet var mainTableView: UITableView!
  @IBOutlet var searchTextField: UITextField!
  var themeList: [ThemaListData] = []
  var delegate: TapTheme?
  
  override func viewDidLoad() {
    mainTableView.delegate = self
    mainTableView.dataSource = self
    searchTextField.delegate = self
  }
  
  @IBAction func tapInitSearch(_ sender: UIButton) {
    themeList.removeAll()
    self.view.endEditing(true)
    initThemeList(searchTextField.text)
  }
  
  
  func initThemeList(_ searchKeyword: String?) {
    let apiurl = "/v1/theme/list"
    
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiurl)")!
    let requestURL = url
      .appending("search", value: searchKeyword ?? nil)
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
            self.mainTableView.reloadData()
          }
        }
        break
      case .failure:
        
        print("error: \(response.error!)")
        break
      }
    }
  }
}
extension CommunityThemeListViewController: UITableViewDelegate, UITableViewDataSource{
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return themeList.count
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    return 95
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = mainTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let dict = themeList[indexPath.row]
    
    var themeName = cell.viewWithTag(1) as! UILabel
    let themeDiff = cell.viewWithTag(2) as! UILabel
    let themeCompany = cell.viewWithTag(3) as! UILabel
    let ratingView = cell.viewWithTag(4) as! CosmosView
    let ratingLabel = cell.viewWithTag(5) as! UILabel
    let likeCountLabel = cell.viewWithTag(6) as! UILabel
    let themeImageView = cell.viewWithTag(7) as! UIImageView
    
    
    themeImageView.kf.setImage(with: URL(string: dict.thumbnail ?? ""))
    themeName.text = dict.title
    themeDiff.text = dict.category
    themeCompany.text = dict.companyName
    ratingView.rating = dict.grade
    ratingLabel.text = "\(dict.grade)"
    likeCountLabel.text = "\(dict.wishCount)"
    
    cell.selectionStyle = .none
    return cell
  }
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let dict = themeList[indexPath.row]

    delegate?.tapDetail(themeId: dict.id, themeName: dict.title, themeCompany: dict.companyName)
    backPress()
  }
  
}
extension CommunityThemeListViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    themeList.removeAll()
    self.view.endEditing(true)
    initThemeList(searchTextField.text)
      return true
  }
}
