//
//  ThemaViewController.swift
//  roomEscape_re
//
//  Created by RightCode_IOS on 2021/12/08.
//

import UIKit
import Alamofire
import SwiftyJSON
import RxSwift
import RxCocoa
import SwiftUI

var selectedAddressFromHomeVC: String?

class ThemaVC: BaseViewController, WishDelegate, UIScrollViewDelegate {
  @IBOutlet weak var areaCollectionView: UICollectionView!
  
  @IBOutlet weak var addressView: UIView!
  @IBOutlet weak var guCollectionView: UICollectionView!
  @IBOutlet weak var genreCollectionView: UICollectionView!
  @IBOutlet weak var contentTableView: UITableView!
  
  var themeList: [ThemaListData] = []
  var themeLevelList: [ThemeLevel] = [.전체, .one, .two, .three, .four, .five]
  var areaList: [AreaList] = [.전국, .서울, .경기, .인천, .충청, .경상, .전라, .강원, .제주]
  var page: Int = 1
  var check: Bool = false
  let genreList: [GenreList] = [.entire, .horror, .adult, .whodunnit, .action, .mellow, .adventure, .sfFantasy, .outdoor]
  
  var selectedArea: AreaList = .전국
  
  var addressList: [String] = []
  var selectedAddress: String = "전체"
  var selectedTableThema: String = ""
  
  var themeFilter = ThemeListRequest()
  var request = ThemeFilterRequest()
  
  var selectedGenre: GenreList = .entire
  
  var getListId: Int = 0
  
  var userId: Int?
  var premuimCount = 0
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initDelegateDatasource()
    initAddress()
    contentTableView.isScrollEnabled = true
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.navigationBar.isHidden = false
    if selectedAddressFromHomeVC != "" && selectedAddressFromHomeVC != nil {
      if(selectedAddressFromHomeVC=="강남"||selectedAddressFromHomeVC=="홍대"||selectedAddressFromHomeVC=="신촌"||selectedAddressFromHomeVC=="건대"||selectedAddressFromHomeVC=="대학로"){
        selectedArea = .서울
        selectedAddress = selectedAddressFromHomeVC ?? "전체"
        selectedGenre = .entire
      }else if(selectedAddressFromHomeVC=="new"){
        selectedAddress = "전체"
        selectedArea = .전국
        selectedGenre = .entire
        self.themeFilter.type = [.신규테마]
      }else if(selectedAddressFromHomeVC=="easy"){
        selectedAddress = "전체"
        selectedArea = .전국
        selectedGenre = .entire
        self.themeFilter.level = [.one,.two]
      }else if(selectedAddressFromHomeVC=="hard"){
        selectedAddress = "전체"
        selectedArea = .전국
        selectedGenre = .entire
        self.themeFilter.level = [.five, .four]
      }else if(selectedAddressFromHomeVC=="공포"){
        selectedAddress = "전체"
        selectedArea = .전국
        selectedGenre = .horror
      }else if(selectedAddressFromHomeVC=="19금"){
        selectedAddress = "전체"
        selectedArea = .전국
        selectedGenre = .adult
      }else if(selectedAddressFromHomeVC=="different"){
        selectedAddress = "전체"
        selectedArea = .전국
        selectedGenre = .entire
        self.themeFilter.type[0] = .이색컨텐츠
      }
      DataHelper<ThemeListRequest>.setThemeListFilter(self.themeFilter)
      initAddress()
      guCollectionView.reloadData()
      genreCollectionView.reloadData()
      areaCollectionView.reloadData()
    }
    if selectedAddressFromHomeVC == "추천테마"{
      recommend()
    }else{
      recommendTheme()
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    selectedAddressFromHomeVC = nil
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "aaa", let vc = segue.destination as? DetailThemaVC, let id = sender as? Int {
      vc.id = id
    }
  }
  
  func initDelegateDatasource() {
    
    areaCollectionView.delegate = self
    areaCollectionView.dataSource = self
    
    guCollectionView.delegate = self
    guCollectionView.dataSource = self
    
    genreCollectionView.delegate = self
    genreCollectionView.dataSource = self
    
    contentTableView.delegate = self
    contentTableView.dataSource = self
  }
  
  
  func initAddress() {
    addressList = selectedArea.getAddressList()
    let gu = addressList
    addressView.isHidden = addressList.count == 0
    guCollectionView.reloadData()
  }
  
  func filter() {
    themeFilter = DataHelperTool.themeListFilter ?? ThemeListRequest()
    request.sort = themeFilter.sort?.rawValue
    
    for count in 0..<(themeFilter.type.count){
      if count == 0{
        if themeFilter.type[count] == .전체{
          request.type = nil
        }else{
          request.type = themeFilter.type[count].rawValue
        }
      }else{
        request.type?.append(",\(themeFilter.type[count].rawValue)")
      }
    }
    for count in 0..<(themeFilter.rate.count){
      if count == 0{
        if themeFilter.rate[count] == .전체{
          request.rate = nil
        }else{
          request.rate = themeFilter.rate[count].rawValue
        }
      }else{
        request.rate?.append(",\(themeFilter.rate[count].rawValue)")
      }
    }
    for count in 0..<(themeFilter.level.count){
      if count == 0{
        if themeFilter.level[count] == .전체{
          request.level = nil
        }else{
          request.level = themeFilter.level[count].rawValue
        }
      }else{
        request.level?.append(",\(themeFilter.level[count].rawValue)")
      }
    }
    for count in 0..<(themeFilter.person.count){
      if count == 0{
        if themeFilter.person[count] == .전체{
          request.person = nil
        }else{
          request.person = "\(themeFilter.person[count].personCount())"
        }
      }else{
        request.person?.append(",\(themeFilter.person[count].personCount())")
      }
    }
    for count in 0..<(themeFilter.tool.count){
      if count == 0{
        if themeFilter.tool[count] == .전체{
          request.tool = nil
        }else{
          request.tool = themeFilter.tool[count].rawValue
        }
      }else{
        request.tool?.append(",\(themeFilter.tool[count].rawValue)")
      }
    }
    
    for count in 0..<(themeFilter.activity.count){
      if count == 0{
        if themeFilter.activity[count] == .전체{
          request.activity = nil
        }else{
          request.activity = themeFilter.activity[count].rawValue
        }
      }else{
        request.activity?.append(",\(themeFilter.activity[count].rawValue)")
      }
    }
    request.isMyReview = themeFilter.isMyReview
    print("\(request)")
    
  }
  
  func recommendTheme() {
    self.filter()
    self.showHUD()
    let apiurl = "/v1/theme/list"
    print("requestURL: \(request.sort)")
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiurl)")!
    let requestURL = url
      .appending("page", value:"1")
      .appending("limit", value: "5")
      .appending("premium", value:"true")
      .appending("area1", value: selectedArea == .전국 ? nil : selectedArea.rawValue)
      .appending("area2", value: selectedAddress == "전체" ? nil : selectedAddress)
      .appending("category", value: selectedGenre == .entire ? nil : selectedGenre.rawValue)
    // 필터 적용
      .appending("sort", value: request.sort  )
      .appending("type", value: request.type )
      .appending("rate", value: request.rate )
      .appending("level", value: request.level )
      .appending("person", value: request.person )
      .appending("tool", value: request.tool )
      .appending("activity", value: request.activity)
      .appending("isMyReview", value: request.isMyReview ?? false ? "true" : "false")
    
    var request = URLRequest(url: requestURL)
    request.httpMethod = HTTPMethod.get.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    AF.request(request).responseJSON { (response) in
      switch response.result {
      case .success(let value):
        let decoder = JSONDecoder()
        let json = JSON(value)
        let jsonData = try? json.rawData()
        print("\(apiurl) responseJson: \(requestURL)")
        print("\(apiurl) responseJson: \(json)")
        
        if let data = jsonData, let value = try? decoder.decode(ThemaListResponse.self, from: data) {
          if value.statusCode == 200 {
            self.premuimCount = value.list.rows.count
            self.themeList = value.list.rows
            
            self.noPremium()
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
  func noPremium(){
    self.showHUD()
    let apiurl = "/v1/theme/list"
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiurl)")!
    let requestURL = url
      .appending("page", value:"\(page)")
      .appending("limit", value: "10")
    // 필터 적용
      .appending("area1", value: selectedArea == .전국 ? nil : selectedArea.rawValue)
      .appending("area2", value: selectedAddress == "전체" ? nil : selectedAddress)
      .appending("category", value: selectedGenre == .entire ? nil : selectedGenre.rawValue)
      .appending("sort", value: request.sort )
      .appending("type", value: request.type )
      .appending("rate", value: request.rate )
      .appending("level", value: request.level )
      .appending("person", value: request.person )
      .appending("tool", value: request.tool )
      .appending("activity", value: request.activity)
      .appending("isMyReview", value: request.isMyReview ?? false ? "true" : "false")
    
    var request = URLRequest(url: requestURL)
    request.httpMethod = HTTPMethod.get.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    AF.request(request).responseJSON { (response) in
      switch response.result {
      case .success(let value):
        let decoder = JSONDecoder()
        let json = JSON(value)
        let jsonData = try? json.rawData()
        print("\(apiurl) responseJson: \(requestURL)")
        print("\(apiurl) responseJson: \(json)")
        
        if let data = jsonData, let value = try? decoder.decode(ThemaListResponse.self, from: data) {
          if value.statusCode == 200 {
            self.themeList.append(contentsOf: value.list.rows)
            if(self.themeList.count + self.premuimCount == value.list.count){
              self.check = false
            }else{
              self.check = true
            }
          }
          self.contentTableView.reloadData()
          self.dismissHUD()
        }
        
        break
      case .failure:
        
        print("error: \(response.error!)")
        self.dismissHUD()
        break
      }
    }
  }
  func recommend() {
    premuimCount = 0
    let apiurl = "/v1/theme/list"
    
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
        
        if let data = jsonData, let value = try? decoder.decode(ThemeDefaultListResponse.self, from: data) {
          if value.statusCode == 200 {
            self.themeList = value.list
            self.check = false
            self.contentTableView.reloadData()
            selectedAddressFromHomeVC = nil
            
            print("\(data)")
          }
        }
        break
      case .failure:
        print("error: \(response.error!)")
        break
      }
    }
  }
  
  @objc func showThemeFilterPopupView() {
    let vc = ThemeFilterPopupView()
    vc.modalPresentationStyle = .custom
    vc.transitioningDelegate = self
    vc.delegate = self
    vc.themeFilter = themeFilter
    self.present(vc, animated: true, completion: nil)
  }
  
  @IBAction func tapFilter(_ sender: Any) {
    //    showThemeFilterPopupView()
    let vc = UIStoryboard.init(name: "Thema", bundle: nil).instantiateViewController(withIdentifier: "themeFilterPopup") as! ThemeFilterPopupView
    vc.delegate = self
    vc.themeFilter = self.themeFilter
    self.present(vc, animated: true, completion: nil)
  }
  
  @IBAction func tapSearch(_ sender: Any) {
    let vc = UIStoryboard.init(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "search") as! SearchVC
    vc.selectedDiff = .테마
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  func reloadRows(index: Int) {
    let indexPath = IndexPath(row: index, section: 0)
    contentTableView.reloadRows(at: [indexPath], with: .automatic)
  }
  
  func didWishButtonTapped(_ index: Int) {
    if DataHelperTool.token == nil {
      callYesNoMSGDialog(message: "로그인이 필요한 기능입니다.\n로그인 하시겠습니까?") {
        self.moveToLogin()
      }
    } else {
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
  
}

extension ThemaVC: ThemeFilterDelegate {
  func setFilter(_ filter: ThemeListRequest) {
    self.page = 1
//    self.themeFilter = filter
//    DataHelper<ThemeListRequest>.setThemeListFilter(self.themeFilter)
    recommendTheme()
  }
}

extension ThemaVC: UIViewControllerTransitioningDelegate {
  func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    PresentationController(presentedViewController: presented, presenting: presenting)
  }
}


extension ThemaVC: UICollectionViewDataSource, UICollectionViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.contentOffset.y > scrollView.contentSize.height-scrollView.bounds.size.height {
      if(check){
        page += 1
        check = false
        noPremium()
      }
    }
    
  }
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView == self.areaCollectionView {
      return areaList.count
    } else if collectionView == self.guCollectionView {
      return addressList.count
    } else {
      return genreList.count
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
    } else if collectionView == self.guCollectionView {
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
    } else if collectionView == self.genreCollectionView {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "genreCollectionCell", for: indexPath) as! GenreCell
      
      
      let genre = genreList[indexPath.row].rawValue
      
      let isEqual = genre == selectedGenre.rawValue
      
      cell.genreLabel.text = genre
      cell.genreLabel.textColor = !isEqual ? UIColor(red: 186/255, green: 186/255, blue: 186/255, alpha: 1.0) : UIColor(red: 152/255, green: 203/255, blue: 86/255, alpha: 1.0)
      
      cell.genreBackgroundView.backgroundColor = !isEqual ?  UIColor.white : UIColor(red: 227/255, green: 255/255, blue: 191/255, alpha: 1.0)
      cell.genreBackgroundView.layer.cornerRadius = 8
      cell.genreBackgroundView.borderWidth = !isEqual ? 1 : 0
      cell.genreBackgroundView.borderColor = !isEqual ? UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1.0) : .clear
      
      return cell
      
    } else {
      return UICollectionViewCell()
    }
    
  }
  //MARK: - didSelectItemAt
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if collectionView == self.areaCollectionView {
      let area = areaList[indexPath.row]
      
      selectedArea = area
      selectedAddress = "전체"
      selectedGenre = .entire
      areaCollectionView.reloadData()
      genreCollectionView.reloadData()
      
      initAddress()
      
      self.page=1
      self.themeList.removeAll()
      contentTableView.reloadData()
      contentTableView.setContentOffset(CGPoint(x: 0, y:0), animated: true)
      recommendTheme()
      
    } else if collectionView == self.guCollectionView {
      
      let gu = addressList[indexPath.row]
      
      selectedAddress = gu
      guCollectionView.reloadData()
      self.page=1
      self.themeList.removeAll()
      contentTableView.reloadData()
      contentTableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
      recommendTheme()
      
    } else if collectionView == self.genreCollectionView {
      
      let genre = genreList[indexPath.row]
      
      selectedGenre = genre
      genreCollectionView.reloadData()
      self.page=1
      self.themeList.removeAll()
      contentTableView.reloadData()
      contentTableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
      recommendTheme()
    } else {
      
    }
    
  }
  
}


extension ThemaVC: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return themeList.count
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = contentTableView.dequeueReusableCell(withIdentifier: "contentTableViewCell", for: indexPath) as! ContentCell
    print("\(themeList.count) , \(indexPath.row)")
    let dict = themeList[indexPath.row]
    cell.initPremiumThemeList(dict,premuimCount,indexPath.row)
    cell.delegate = self
    cell.index = indexPath.row
    
    cell.selectionStyle = .none
    
    return cell
    
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    //     = contentTableView.contentSize.height
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let dict = themeList[indexPath.row]
    let vc = UIStoryboard.init(name: "Thema", bundle: nil).instantiateViewController(withIdentifier: "DetailThemaVC") as! DetailThemaVC
    vc.id = dict.id
    self.navigationController?.pushViewController(vc, animated: true)
    
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    return 210
  }
  
}
