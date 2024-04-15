//
//  CafeVC.swift
//  roomEscape_re
//
//  Created by hoon Kim on 2022/02/01.
//

import UIKit
import Alamofire
import SwiftyJSON

enum CafeSortDiff: String, Codable {
  case 전방추천순 = "전방 추천순"
  case 리뷰많은순 = "리뷰 많은순"
  case 평점높은순 = "평점 높은순"
  case 거리순 = "거리순"
}

enum CafeTypeDiff: String, Codable {
  case new = "신규업체"
  case different = "이색 컨텐츠"
  case only = "혼방가능"
  case foreign = "외국어 가능"
}
var selectedAddressFromCafeVC: String?

class CafeVC: BaseViewController, WishDelegate {
  
  @IBOutlet weak var areaCollectionView: UICollectionView!
  
  @IBOutlet weak var addressView: UIView!
  @IBOutlet weak var guCollectionView: UICollectionView!
  
  @IBOutlet weak var tableView: UITableView!
  
  var selectedArea: AreaList = .전국
  var page: Int = 1
  var check: Bool = false
  
  let areaList: [AreaList] = [.전국, .서울, .경기, .인천, .충청, .경상, .전라, .강원, .제주]
  
  var addressList: [String] = []
  var selectedAddress: String = "전체"
  
  var cafeList: [CompanyListData] = []
  
  var sort: CafeSortDiff = .전방추천순
  
  var typeArray: [CafeTypeDiff] = []{
    didSet{
      tableView.scrollToRow(at: IndexPath(row: NSNotFound, section: 0), at: .top, animated: false)
    }
  }
  
  var premuimCount = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //      let indexPath :IndexPath = IndexPath(row: 0 , section: 0)
    //      self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
    
    initCafeList()
    initDelegateDatasource()
    self.page=1
  }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.setNavigationBarHidden(false, animated: true)
    navigationController?.navigationBar.isHidden = false
    if(selectedAddressFromCafeVC == "different"){
      typeArray.removeAll()
      typeArray.append(.different)
    }
    if selectedAddressFromCafeVC == "추천카페"{
      cafeList.removeAll()
      recommendCafe()
    }
  }
  
  func initDelegateDatasource() {
    areaCollectionView.delegate = self
    areaCollectionView.dataSource = self
    
    guCollectionView.delegate = self
    guCollectionView.dataSource = self
    
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  func initAddress() {
    addressList = selectedArea.getAddressList()
    let gu = addressList
    print("\(gu)")
    addressView.isHidden = addressList.count == 0
    guCollectionView.reloadData()
    
    tableView.layoutTableHeaderView()
  }
  
  func initCafeList() {
    self.showHUD()
    let apiurl = "/v1/company/list"
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiurl)")!
    let requestURL = url
      .appending("page", value:"1")
      .appending("limit", value: "5")
      .appending("premium", value:"true")
      .appending("area1", value: selectedArea == .전국 ? nil : selectedArea.rawValue)
      .appending("area2", value: selectedAddress == "전체" ? nil : selectedAddress)
    //필터적용
      .appending("typeNew", value: typeArray.contains(.new) ? "true" : nil)
      .appending("typeDifferent", value: typeArray.contains(.different) ? "true" : nil)
      .appending("typeOnly", value: typeArray.contains(.only) ? "true" : nil)
      .appending("typeForeign", value: typeArray.contains(.foreign) ? "true" : nil)
    
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
        if let data = jsonData, let value = try? decoder.decode(CompanyDefaultListResponse.self, from: data) {
          if value.statusCode == 200 {
            self.cafeList.removeAll()
            self.premuimCount = value.list.rows.count
            self.cafeList = value.list.rows
            self.noPremium()
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
  func noPremium() {
    self.showHUD()
    let apiurl = "/v1/company/list"
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiurl)")!
    let requestURL = url
      .appending("page", value:"\(page)")
      .appending("limit", value: "10")
      .appending("area1", value: selectedArea == .전국 ? nil : selectedArea.rawValue)
      .appending("area2", value: selectedAddress == "전체" ? nil : selectedAddress)
      .appending("sort", value: sort.rawValue)
      .appending("typeNew", value: typeArray.contains(.new) ? "true" : nil)
      .appending("typeDifferent", value: typeArray.contains(.different) ? "true" : nil)
      .appending("typeOnly", value: typeArray.contains(.only) ? "true" : nil)
      .appending("typeForeign", value: typeArray.contains(.foreign) ? "true" : nil)
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
        if let data = jsonData, let value = try? decoder.decode(CompanyDefaultListResponse.self, from: data) {
          if value.statusCode == 200 {
            self.cafeList.append(contentsOf: value.list.rows)
            self.tableView.reloadData()
            if(self.cafeList.count + self.premuimCount == value.list.count){
              self.check = false
            }else{
              self.check = true
            }
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
  
  func reloadRows(index: Int) {
    let indexPath = IndexPath(row: index, section: 0)
    tableView.reloadRows(at: [indexPath], with: .automatic)
  }
  func recommendCafe() {
    premuimCount = 0
    let apiurl = "/v1/company/list"
    
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiurl)")!
    let requestURL = url
      .appending("main", value: "true")
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
        if let data = jsonData, let value = try? decoder.decode(CompanyListResponse.self, from: data) {
          if value.statusCode == 200 {
            self.cafeList = value.list
            self.check = false
            self.tableView.reloadData()
            selectedAddressFromCafeVC = nil
          }
        }
        break
      case .failure:
        
        print("error: \(response.error!)")
        break
      }
    }
  }
  
  func didWishButtonTapped(_ index: Int) {
    if DataHelperTool.token == nil {
      callYesNoMSGDialog(message: "로그인이 필요한 기능입니다.\n로그인 하시겠습니까?") {
        self.moveToLogin()
      }
    } else {
      let dict = cafeList[index]
      
      let isWish = dict.isWish ? false : true
      cafeWish(dict.id, isWish) { value in
        if value.statusCode <= 201 {
          self.cafeList[index].isWish = isWish
          self.cafeList[index].wishCount = (isWish ? self.cafeList[index].wishCount + 1 : self.cafeList[index].wishCount - 1)
          self.reloadRows(index: index)
        }
      }
    }
  }
  
  func moveToFilter() {
    let vc = UIStoryboard.init(name: "Cafe", bundle: nil).instantiateViewController(withIdentifier: "cafeFilterPopup") as! CafeFilterPopupVC
    vc.delegate = self
    vc.selectedSort = sort
    vc.selectedTypeList = typeArray
    self.present(vc, animated: true, completion: nil)
  }
  
  @IBAction func tapSearch(_ sender: Any) {
    let vc = UIStoryboard.init(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "search") as! SearchVC
    vc.selectedDiff = .카페
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  @IBAction func tapFilter(_ sender: Any) {
    moveToFilter()
  }
}

extension CafeVC: CafeFilterDelegate {
  func selectedFilter(sort: CafeSortDiff, typeList: [CafeTypeDiff]) {
    self.sort = sort
    self.typeArray.removeAll()
    print(typeList)
    self.typeArray = typeList
    self.page=1
    cafeList.removeAll()
    initCafeList()
  }
}

extension CafeVC: UICollectionViewDataSource, UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView == self.areaCollectionView {
      return areaList.count
    } else {
      return addressList.count
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if collectionView == self.areaCollectionView {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "areaCollectionCell", for: indexPath) as! AreaCell
      
      let area = areaList[indexPath.row].rawValue
      let isEqual = area == selectedArea.rawValue
      print("\(area) - \(selectedArea.rawValue) : \(isEqual)")
      
      cell.areaLabel.text = area
      cell.areaBottomView.isHidden = !(isEqual)
      
      cell.areaLabel.textColor =  isEqual ? UIColor.black : UIColor.lightGray
      
      return cell
    } else {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "guCollectionCell", for: indexPath) as! GuCell
      
      let gu = addressList[indexPath.row]
      
      let isEqual = gu == selectedAddress
      
      cell.guLabel.text = gu
      cell.guLabel.textColor = !isEqual ? UIColor(red: 186/255, green: 186/255, blue: 186/255, alpha: 1.0) : UIColor(red: 244/255, green: 166/255, blue: 31/255, alpha: 1.0)
      
      cell.guBackgroundView.backgroundColor = !isEqual ? .white : UIColor(red: 255/255, green: 239/255, blue: 188/255, alpha: 1.0)
      
      cell.guBackgroundView.layer.cornerRadius = 8
      cell.guBackgroundView.borderWidth = !isEqual ? 1 : 0
      cell.guBackgroundView.borderColor = !isEqual ? UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1.0) : .clear
      
      return cell
    }
    
  }
  //MARK: - didSelectItemAt
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    self.page=1
    cafeList.removeAll()
    tableView.reloadData()
    if collectionView == self.areaCollectionView {
      let area = areaList[indexPath.row]
      
      selectedArea = area
      areaCollectionView.reloadData()
      selectedAddress = "전체"
      initAddress()
      initCafeList()
    } else {
      let gu = addressList[indexPath.row]
      
      selectedAddress = gu
      guCollectionView.reloadData()
      initCafeList()
    }
  }
  
}

extension CafeVC: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return cafeList.count
  }
  
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.contentOffset.y > scrollView.contentSize.height-scrollView.bounds.size.height {
      print("\(check) !!!!! \(selectedAddressFromCafeVC)")
      if(check){
        page += 1
        check = false
        noPremium()
      }
    }
    
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.tableView.dequeueReusableCell(withIdentifier: "cafeListCell", for: indexPath) as! CafeListCell
    let dict = cafeList[indexPath.row]
    cell.initCompanyListData(dict,premuimCount,indexPath.row)
    cell.delegate = self
    cell.index = indexPath.row
    
    cell.selectionStyle = .none
    
    return cell
    
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let dict = cafeList[indexPath.row]
    
    let vc = UIStoryboard.init(name: "Cafe", bundle: nil).instantiateViewController(withIdentifier: "cafeDetail") as! CafeDetailVC
    vc.id = dict.id
    self.goViewController(vc: vc)
    
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    return 250
  }
  
}
