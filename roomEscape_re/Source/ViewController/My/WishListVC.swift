//
//  WishListVC.swift
//  roomEscape_re
//
//  Created by hoon Kim on 2022/02/01.
//

import UIKit
import Alamofire
import SwiftyJSON

enum WishDiff: String, Codable {
  case 테마
  case 카페
}

class WishListVC: BaseViewController, WishDelegate {
  
  @IBOutlet weak var diffCollectionView: UICollectionView!
  
  @IBOutlet weak var nothingWishImageView: UIImageView!
  @IBOutlet weak var tableView: UITableView!
  
  let diffList: [WishDiff] = [.테마, .카페]
  
  var selectedDiff: WishDiff = .테마
  
  var cafeList: [WishCompanyListData] = []
  
  var themeList: [ThemaListData] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    
    diffCollectionView.delegate = self
    diffCollectionView.dataSource = self
    
    initThemeList()
    initCafeList()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.navigationBar.isHidden = false
  }
  
  func initNothingImageView() {
    if selectedDiff == .테마 {
      tableView.isHidden = themeList.count <= 0
      nothingWishImageView.isHidden = themeList.count > 0
    } else {
      tableView.isHidden = cafeList.count <= 0
      nothingWishImageView.isHidden = cafeList.count > 0
    }
  }
  
  func initThemeList() {
    let apiurl = "/v1/theme/list"
    
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiurl)")!
    let requestURL = url
      .appending("isWish", value: "true")
    var request = URLRequest(url: requestURL)
    request.httpMethod = HTTPMethod.get.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("\(DataHelperTool.token ?? "")", forHTTPHeaderField: "Authorization")
    
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
          }
        }
        break
      case .failure:
        
        print("error: \(response.error!)")
        break
      }
    }
  }
  
  func initCafeList() {
    let apiurl = "/v1/company/list"
    
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiurl)")!
    let requestURL = url
      .appending("isWish", value: "true")
    var request = URLRequest(url: requestURL)
    request.httpMethod = HTTPMethod.get.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("\(DataHelperTool.token ?? "")", forHTTPHeaderField: "Authorization")
    
    AF.request(request).responseJSON { (response) in
      switch response.result {
      case .success(let value):
        let decoder = JSONDecoder()
        let json = JSON(value)
        let jsonData = try? json.rawData()
        print("\(apiurl) responseJson: \(json)")
        if let data = jsonData, let value = try? decoder.decode(CompanyWishListResponse.self, from: data) {
          if value.statusCode == 200 {
            print("!!")
              self.cafeList = value.list
            self.tableView.reloadData()
            self.initNothingImageView()
          }
        }
        break
      case .failure:
        
        print("error: \(response.error!)")
        break
      }
    }
  }
  
  func reloadRows(index: Int) {
    let indexPath = IndexPath(row: index, section: 0)
    tableView.reloadRows(at: [indexPath], with: .automatic)
  }
  
  func didWishButtonTapped(_ index: Int) {
    if selectedDiff == .테마 {
      let dict = themeList[index]
      
      let isWish = dict.isWish ? false : true
      themeWish(dict.id, isWish) { value in
        if value.statusCode <= 201 {
          self.themeList.remove(at: index)
          self.tableView.reloadData()
        }
      }
    } else {
      let dict = cafeList[index]
      
      let isWish = dict.isWish ? false : true
      cafeWish(dict.id, isWish) { value in
        if value.statusCode <= 201 {
          self.cafeList.remove(at: index)
          self.tableView.reloadData()
        }
      }
    }
  }
  
}

extension WishListVC: UICollectionViewDataSource, UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return diffList.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = diffCollectionView.dequeueReusableCell(withReuseIdentifier: "areaCollectionCell", for: indexPath) as! AreaCell
    
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
    diffCollectionView.reloadData()
    
    tableView.reloadData()
    initNothingImageView()
  }
  
}
//MARK: UICollectionViewDelegateFlowLayout
extension WishListVC: UICollectionViewDelegateFlowLayout {
  //Cell Size
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: (APP_WIDTH() - 30) / 2, height: 38)
  }
  
  //CollectionView Inset
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
  }
  
  //Side Margin Between Cell
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
  //Top & Bottom Margin Between Cell
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
}

extension WishListVC: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return selectedDiff == .테마 ? themeList.count : cafeList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if selectedDiff == .테마 {
      let cell = self.tableView.dequeueReusableCell(withIdentifier: "contentTableViewCell", for: indexPath) as! ContentCell
      let dict = themeList[indexPath.row]
      cell.initContentList(dict)
      cell.delegate = self
      cell.index = indexPath.row
      cell.selectionStyle = .none
      
      return cell
    } else {
      let cell = self.tableView.dequeueReusableCell(withIdentifier: "cafeListCell", for: indexPath) as! CafeListCell
      let dict = cafeList[indexPath.row]
      cell.initWithCompanyListData(dict)
      cell.delegate = self
      cell.index = indexPath.row
      cell.selectionStyle = .none
      
      return cell
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if selectedDiff == .테마 {
      let dict = themeList[indexPath.row]
      
      let vc = UIStoryboard.init(name: "Thema", bundle: nil).instantiateViewController(withIdentifier: "DetailThemaVC") as! DetailThemaVC
      vc.id = dict.id
      self.goViewController(vc: vc)
    } else {
      let dict = cafeList[indexPath.row]
      
      //    let vc = UIStoryboard.init(name: "Thema", bundle: nil).instantiateViewController(withIdentifier: "DetailThemaVC") as! DetailThemaVC
      //
      //    vc.id = dict.id
      //
      //    self.goViewController(vc: vc)
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    return selectedDiff == .테마 ? 210 : 250
  }
  
}
