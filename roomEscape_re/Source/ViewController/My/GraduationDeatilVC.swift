//
//  GraduationDeatilVC.swift
//  roomEscape_re
//
//  Created by 이남기 on 2022/10/17.
//

import Foundation
import UIKit
import SwiftUI
import Alamofire
import SwiftyJSON

enum GraduationDiff: String, Codable {
  case 졸업한매장 = "졸업한 매장"
  case 졸업안한매장 = "졸업 안한 매장"
}
class GraduationDeatilVC:BaseViewController{
  
  @IBOutlet var mainCollectionView: UICollectionView!
  @IBOutlet var mainTableView: UITableView!
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var searchButton: UIButton!
    
  var area : String?
  var area1 : String?
  var list: [GraduationCompanyListData] = []
  
  let diffList: [GraduationDiff] = [.졸업한매장, .졸업안한매장]
  
  var selectedDiff: GraduationDiff = .졸업한매장
  
  override func viewDidLoad() {
    mainTableView.delegate = self
    mainTableView.dataSource = self
    
    mainCollectionView.delegate = self
    mainCollectionView.dataSource = self
    initCafeList(graduate: "true")
  }
  
  func initCafeList(graduate: String) {
    self.showHUD()
    let apiurl = "/v1/company/userList"
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiurl)")!
      let requestURL = url
        .appending("isGraduation", value: "\(graduate)")
        .appending("area", value: area != nil ? area : nil)
        .appending("area1", value: area1 != nil ? area1 : nil )
        .appending("companyName", value: searchTextField.text?.isEmpty ?? true ? nil : searchTextField.text)
    
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
        if let data = jsonData, let value = try? decoder.decode(CompanyGradutaionListResponse.self, from: data) {
          if value.statusCode == 200 {
            print("!!!")
            self.list = value.list
            self.mainTableView.reloadData()
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
    @IBAction func tapSearch(_ sender: Any) {
        if selectedDiff == .졸업한매장{
            initCafeList(graduate: "true")
        }else{
          initCafeList(graduate: "false")
        }
    }
}
extension GraduationDeatilVC:UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return list.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GraduationCell
    let dict = list[indexPath.row]
    cell.initdelegate(data: dict)
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let dict = list[indexPath.row]
    return CGFloat(159 + ( 21 * dict.themes.count))
  }
  
}
extension GraduationDeatilVC: UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return diffList.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: "areaCollectionCell", for: indexPath) as! AreaCell
    
    let diff = diffList[indexPath.row]
    let isEqual = diff == selectedDiff
    
    cell.areaLabel.text = diff.rawValue
    cell.areaBottomView.isHidden = !(isEqual)
    
    cell.areaLabel.textColor =  isEqual ? UIColor.black : UIColor.lightGray
    
    
    return cell
    
  }
  
  //MARK: - didSelectItemAt
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let diff = diffList[indexPath.row]
    
    selectedDiff = diff
    mainCollectionView.reloadData()
    
    if selectedDiff == .졸업한매장{
      initCafeList(graduate: "true")
    }else{
      initCafeList(graduate: "false")
    }
    
  }
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = mainCollectionView.bounds.size.width / 2
    return CGSize(width: width , height: 40)
  }
  
}
