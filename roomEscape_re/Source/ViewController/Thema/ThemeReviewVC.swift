//
//  ThemeReviewVC.swift
//  roomEscape_re
//
//  Created by hoon Kim on 2022/02/03.
//

import UIKit
import Cosmos
import Alamofire
import SwiftyJSON

class ThemeReviewVC: BaseViewController {
  
  @IBOutlet weak var reviewRatingView: CosmosView!
  @IBOutlet weak var reviewRatingLabel: UILabel!
  @IBOutlet weak var reviewCountLabel: UILabel!
  @IBOutlet weak var reviewFilterButton: UIButton!
  
  @IBOutlet var backButton: UIButton!
  @IBOutlet var sortButton: UILabel!
  @IBOutlet weak var reviewTableView: UITableView!
  
  var detailData: ThemaDetailData?
  
  var reviewList: [ThemeReview] = []
    var page: Int = 1
    var check: Bool = false
  var selectSort: String = "최신순"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    reviewTableView.delegate = self
    reviewTableView.dataSource = self
      reviewTableView.isScrollEnabled = true

    initWithThemeDetailData(detailData!)
    reviewTableView.layoutTableHeaderView()
    initrx()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.isNavigationBarHidden = true
    themeReviewList()
  }
  
  func initWithThemeDetailData(_ data: ThemaDetailData) {
    reviewRatingView.rating = data.grade
    reviewRatingView.settings.fillMode = .half
    reviewRatingLabel.text = "\(data.grade)"
  }
  
  func removeReview(_ reviewId: Int) {
    let apiurl = "/v1/themeReview/remove"
    
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
        
        if let data = jsonData, let value = try? decoder.decode(DefaultResponse.self, from: data) {
          if value.statusCode == 200 {
            self.themeReviewList()
          }
        }
        break
      case .failure:
        print("error: \(response.error!)")
        break
      }
    }
  }
  
  func themeReviewList(append:Bool = false) {
    let apiurl = "/v1/themeReview/list"
    
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiurl)")!
    let requestURL = url
          .appending("limit", value: "10")
          .appending("page", value: "\(page)")
      .appending("themeId", value: "\(detailData?.id ?? 0)")
      .appending("sort", value:selectSort)
    
    var request = URLRequest(url: requestURL)
    request.httpMethod = HTTPMethod.get.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    print(selectSort)
    print(requestURL)
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
            self.reviewCountLabel.text = "\(value.list.count)"
            self.reviewTableView.reloadData()
              if(self.reviewList.count == value.list.count){
                  self.check = false
              }else{
                  self.check = true
              }
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
        })
        .disposed(by: disposeBag)
    
    backButton.rx.tap.bind(onNext: { [weak self] _ in
        self?.backPress()
      })
      .disposed(by: disposeBag)
  }
  
  @IBAction func tapRegistReview(_ sender: UIButton) {
      if(detailData!.isReview){
          callOkActionMSGDialog(message: "이미 작성한 리뷰입니다!"){
          }
      }else{
        let vc = UIStoryboard.init(name: "Thema", bundle: nil).instantiateViewController(withIdentifier: "registThemeReview") as! RegistThemeReviewVC
        vc.themeDetailData = detailData
        self.navigationController?.pushViewController(vc, animated: true)
      }
  }
  
}

extension ThemeReviewVC: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return reviewList.count
  }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
                      if scrollView.contentOffset.y > scrollView.contentSize.height-scrollView.bounds.size.height {
                          if(check){
                                  page += 1
                                  check = false
                              themeReviewList()
                          }
                      }
        
    }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = reviewTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ReviewCell
    cell.delegate = self
    let dict = reviewList[indexPath.row]
    cell.initWithThemeReview(dict,indexPath)
    
    cell.lineView.isHidden = indexPath.row == (reviewList.count - 1)
    cell.isMineView.isHidden = (DataHelperTool.userAppId ?? 0) != dict.userId
    
    cell.selectionStyle = .none
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
}
extension ThemeReviewVC: ReviewCellMyButtonsDelegate{
  func didGoUserReview(_ index: IndexPath) {
      let vc = UIStoryboard.init(name: "My", bundle: nil).instantiateViewController(withIdentifier: "MyReviewListVC") as! MyReviewListVC
      vc.isOther = true
    vc.userName = reviewList[index.row].userName
      self.navigationController?.pushViewController(vc, animated: true)
  }
  
  func didRemoveButtonTapped(_ index: IndexPath) {
    callYesNoMSGDialog(message: "해당 리뷰를 삭제하시겠습니까?") {
      self.removeReview(self.reviewList[index.row].id)
    }
  }
  func didUpdateButtonTapped(_ index: IndexPath) {
    let vc = UIStoryboard.init(name: "Thema", bundle: nil).instantiateViewController(withIdentifier: "registThemeReview") as! RegistThemeReviewVC
    vc.themeDetailData = detailData
    vc.reviewData = reviewList[index.row]
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  
}
extension ThemeReviewVC: SortFilterDelegate{
  func setFilter(sort: String) {
    selectSort = sort
    page = 1
    reviewList.removeAll()
    sortButton.text = sort
    themeReviewList()
  }
  
  
}


