//
//  CafeReviewVC.swift
//  roomEscape_re
//
//  Created by hoon Kim on 2022/02/04.
//

import UIKit
import Alamofire
import SwiftyJSON
import RxSwift
import Cosmos

class CafeReviewVC: BaseViewController, ReviewCellMyButtonsDelegate {
  
  
  
  
  @IBOutlet weak var reviewRatingView: CosmosView!
  @IBOutlet weak var reviewRatingLabel: UILabel!
  @IBOutlet weak var reviewCountLabel: UILabel!
  @IBOutlet weak var reviewFilterButton: UIButton!
  
  @IBOutlet var sortButton: UIBarButtonItem!
  
  @IBOutlet weak var reviewTableView: UITableView!
  
  var cafeDetailData: CompanyDetailData!
  var reviewList: [CompanyReview] = []
  var selectSort: String = "최신순"
  
  override func viewDidLoad() {
    super.viewDidLoad()
      reviewTableView.isScrollEnabled = true
    reviewTableView.delegate = self
    reviewTableView.dataSource = self
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    companyReviewList()
  }
  
  func companyReviewList() {
    let apiurl = "/v1/companyReview/list"
    
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiurl)")!
    let requestURL = url
      .appending("companyId", value: "\(cafeDetailData.id)")
      .appending("sort", value:selectSort)
    
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
        
        if let data = jsonData, let value = try? decoder.decode(CompanyReviewResponse.self, from: data) {
          if value.statusCode == 200 {
            self.reviewList = value.list
            self.reviewRatingView.rating = self.cafeDetailData.averageRate
            self.reviewCountLabel.text = "\(self.cafeDetailData.averageRate)점 (\(self.reviewList.count))"
            self.reviewTableView.reloadData()
          }
        }
        break
      case .failure:
        print("error: \(response.error!)")
        break
      }
    }
  }
  
  func removeReview(_ reviewId: Int) {
    let apiurl = "/v1/companyReview/remove"
    
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiurl)")!
    let requestURL = url
      .appending("id", value: "\(reviewId)")
    
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
        
        if let data = jsonData, let value = try? decoder.decode(ThemeReviewResponse.self, from: data) {
          if value.statusCode == 200 {
            self.companyReviewList()
          }
        }
        break
      case .failure:
        print("error: \(response.error!)")
        break
      }
    }
  }
  
  @IBAction func tapFilter(_ sender: Any) {
    let vc = UIStoryboard.init(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "SortFilterViewController") as! SortFilterViewController
    vc.delegate = self
    vc.diff = true // 카페 리뷰 필터 
    vc.selectSort = self.selectSort
    self.present(vc, animated: true, completion: nil)
  }
  @IBAction func tapRegistReview(_ sender: UIButton) {
    let vc = UIStoryboard.init(name: "Cafe", bundle: nil).instantiateViewController(withIdentifier: "registCafeReview") as! RegistCafeReviewVC
    vc.companyId = cafeDetailData.id
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  func didUpdateButtonTapped(_ index: IndexPath) {
    let vc = UIStoryboard.init(name: "Cafe", bundle: nil).instantiateViewController(withIdentifier: "registCafeReview") as! RegistCafeReviewVC
    vc.companyId = cafeDetailData.id
    vc.reviewData = reviewList[index.row]
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  func didRemoveButtonTapped(_ index: IndexPath) {
    callYesNoMSGDialog(message: "해당 리뷰를 삭제하시겠습니까?") {
      self.removeReview(self.reviewList[index.row].id)
    }
  }
  func didGoUserReview(_ index: IndexPath) {
  }
  
  func didReportUser(_ reviewId: Int, _ index: IndexPath) {
  }
}
extension CafeReviewVC: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return reviewList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = reviewTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ReviewCell
    let dict = reviewList[indexPath.row]
    
    cell.delegate = self
    cell.index = indexPath
    
    cell.initWithCompanyReview(dict)
    
    cell.lineView.isHidden = indexPath.row == (reviewList.count - 1)
    cell.isMineView.isHidden = (DataHelperTool.userAppId ?? 0) != dict.userId
    
    cell.selectionStyle = .none
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
}
extension CafeReviewVC: SortFilterDelegate{
  func setFilter(sort: String) {
    selectSort = sort
    sortButton.title = sort
    companyReviewList()
  }
}
