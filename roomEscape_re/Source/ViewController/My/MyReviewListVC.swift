//
//  MyReviewListVC.swift
//  roomEscape_re
//
//  Created by hoon Kim on 2022/02/23.
//

import UIKit
import Cosmos
import Alamofire
import SwiftyJSON
import SwiftUI

class MyReviewListVC: BaseViewController {
  @IBOutlet var searchView: UIView!
  @IBOutlet var searchTextField: UITextField!
  
  @IBOutlet weak var reviewCountLabel: UILabel!
  
  @IBOutlet weak var reviewTableView: UITableView!
  
  @IBOutlet var backButton: UIButton!
  @IBOutlet var sortButton: UILabel!
  
  var selectSort: String = "최신순"
  
  var index: IndexPath?
  var detailData: ThemaDetailData?
  var check : Bool = false
  var page : Int = 1
  var isOther: Bool = false
  var userName: String?
  
  var reviewList: [ThemeReview] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    reviewTableView.delegate = self
    reviewTableView.dataSource = self
    reviewTableView.layoutTableHeaderView()
    initrx()
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.navigationBar.isHidden = true
    initWithIsOther()
    if(!isOther && index != nil){
      themeReviewList(index!,nil)
    }else if !isOther{
      themeReviewList()
    }else{
    }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    if !textField.text!.isEmpty {
      self.reviewList.removeAll()
      self.themeReviewList()
    }
    return true
  }
  
  func initWithIsOther() {
    navigationItem.title = isOther ? "다른 사람 리뷰 보기" : "내 리뷰"
    searchView.isHidden = !isOther
  }
  
  func detailThema(_ index:IndexPath) {
    let apiurl = "/v1/theme/detail"
    
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiurl)")!
    let requestURL = url
      .appending("id", value: "\(self.reviewList[index.row].themeId)")
    
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
        
        if let data = jsonData, let value = try? decoder.decode(ThemaDetailResponse.self, from: data) {
          if value.statusCode == 200 {
            let vc = UIStoryboard.init(name: "Thema", bundle: nil).instantiateViewController(withIdentifier: "registThemeReview") as! RegistThemeReviewVC
            vc.themeDetailData = value.data
            vc.reviewData = self.reviewList[index.row]
            self.navigationController?.pushViewController(vc, animated: true)
          }
        }
        break
      case .failure:
        print("error: \(response.error!)")
        break
      }
    }
  }
  
  func themeReviewList() {
    self.showHUD()
    let apiurl = "/v1/themeReview/list"
    
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiurl)")!
    let requestURL : URL
    if(isOther){
      userName = searchTextField.text!.isEmpty ? userName : searchTextField.text
      requestURL = url
        .appending("page", value:"\(page)")
        .appending("limit", value: "10")
        .appending("userName", value: userName)
        .appending("sort", value:selectSort)
    }else{
      requestURL = url
        .appending("page", value:"\(page)")
        .appending("limit", value: "10")
        .appending("userId", value: isOther ? nil : "\(DataHelperTool.userAppId ?? 0)")
    }
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
            
            self.reviewList.append(contentsOf: value.list.rows)
            self.reviewTableView.reloadData()
            self.reviewCountLabel.text = "\(value.list.count)개의 리뷰"
            
            if(self.reviewList.count == value.list.count){
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
        break
      }
    }
  }
  
  func themeReviewList(_ index:IndexPath,_ stata: String?) {
    self.showHUD()
    let apiurl = "/v1/themeReview/list"
    
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiurl)")!
    let requestURL = url
      .appending("userId", value: isOther ? nil : "\(DataHelperTool.userAppId ?? 0)")
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
        
        if let data = jsonData, let value = try? decoder.decode(DefualtThemeReviewResponse.self, from: data) {
          if value.statusCode == 200 {
            if stata == "삭제"{
              self.reviewList.remove(at: index.row)
              self.reviewTableView.deleteRows(at: [index], with: .none)
              self.reviewCountLabel.text = "\(value.list.count)개의 리뷰"
            }else{
              self.reviewList[index.row] = value.list[index.row]
              self.reviewTableView.reloadRows(at: [index], with: .none)
            }
            if(self.reviewList.count == value.list.count){
              self.check = false
            }else{
              self.check = true
            }
            self.index = nil
            
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
  func initrx(){
    
    sortButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        let vc = UIStoryboard.init(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "SortFilterViewController") as! SortFilterViewController
        vc.delegate = self
        vc.selectSort = self?.selectSort ?? "최신순"
        self?.present(vc, animated: true, completion: nil)
      }).disposed(by: disposeBag)
    
    backButton.rx.tap.bind(onNext: { [weak self] _ in
        self?.backPress()
      })
      .disposed(by: disposeBag)
    
  }
  
  
  @IBAction func tapSearch(_ sender: UIButton) {
    reviewList.removeAll()
    themeReviewList()
  }
  
}

extension MyReviewListVC: UITableViewDelegate, UITableViewDataSource {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.contentOffset.y > scrollView.contentSize.height-scrollView.bounds.size.height {
      if(check){
        page += 1
        check = false
        themeReviewList()
      }
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return reviewList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = reviewTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ThemeReviewListCell
    let dict = reviewList[indexPath.row]
    cell.delegate = self
    
    cell.initWithThemeReview(dict,indexPath)
    
    cell.lineView.isHidden = indexPath.row == (reviewList.count - 1)
    cell.isMineView.isHidden = (DataHelperTool.userAppId ?? 0) != dict.userId
    
    cell.selectionStyle = .none
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let dict = reviewList[indexPath.row]
    let vc = UIStoryboard.init(name: "Thema", bundle: nil).instantiateViewController(withIdentifier: "DetailThemaVC") as! DetailThemaVC
    vc.id = dict.themeId
    self.goViewController(vc: vc)
  }
  
}
extension MyReviewListVC:ReviewCellMyButtonsDelegate{
  func didReportUser(_ reviewId: Int, _ index: IndexPath) {
  }
  
  func didGoUserReview(_ index: IndexPath) {
        let vc = UIStoryboard.init(name: "My", bundle: nil).instantiateViewController(withIdentifier: "MyReviewListVC") as! MyReviewListVC
        vc.isOther = true
      vc.searchTextField.text = reviewList[index.row].userName
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  func didRemoveButtonTapped(_ index: IndexPath) {
    callYesNoMSGDialog(message: "해당 리뷰를 삭제하시겠습니까?") {
      self.removeReview(index)
    }
  }
  func didUpdateButtonTapped(_ index: IndexPath) {
    self.index = index
    detailThema(index)
  }
  func removeReview(_ reviewId: IndexPath) {
    let apiurl = "/v1/themeReview/remove"
    
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiurl)")!
    let requestURL = url
      .appending("id", value: "\(reviewList[reviewId.row].id)")
    
    var request = URLRequest(url: requestURL)
    request.httpMethod = HTTPMethod.delete.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    
    AF.request(request).responseJSON { (response) in
      switch response.result {
      case .success(let value):
        let decoder = JSONDecoder()
        let json = JSON(value)
        let jsonData = try? json.rawData()
        print("\(apiurl) responseJson: \(json)")
        
        if let data = jsonData, let value = try? decoder.decode(DefaultResponse.self, from: data) {
          if value.statusCode == 200 {
            self.themeReviewList(reviewId,"삭제")
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

extension MyReviewListVC: SortFilterDelegate{
  func setFilter(sort: String) {
    selectSort = sort
    page = 1
    reviewList.removeAll()
    sortButton.text = sort
    themeReviewList()
  }
}

