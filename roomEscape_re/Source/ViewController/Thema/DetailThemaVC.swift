//
//  DetailThemaVC.swift
//  roomEscape_re
//
//  Created by RightCode_IOS on 2021/12/10.
//

import UIKit
import Kingfisher
import Alamofire
import SwiftyJSON
import RxSwift
import Cosmos

class DetailThemaVC: BaseViewController, ReviewCellMyButtonsDelegate {
  
  @IBOutlet weak var thumbnailView: UIView!
  @IBOutlet weak var mainCollectionView: UICollectionView!
  @IBOutlet weak var mainCollectionViewHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var imageCountLabel: UILabel!
  @IBOutlet weak var imageLabelBackView: UIView!
  
  @IBOutlet weak var wishBarButton: UIBarButtonItem!
  // 디테일 정보
  @IBOutlet weak var newImageView: UIImageView!
  @IBOutlet weak var differentImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!
  @IBOutlet weak var ratesView: CosmosView!
  @IBOutlet weak var scoreView: UILabel!
  
  @IBOutlet weak var wishView: UIImageView!
  @IBOutlet weak var wishScoreLabel: UILabel!
  @IBOutlet weak var levelStackView: UIStackView!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var featureLabel: UILabel!
  
  @IBOutlet weak var contentLabel: UILabel!
  
  @IBOutlet weak var priceView: UIView!
  @IBOutlet weak var feeTableView: UITableView!
  @IBOutlet weak var feeTableViewHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var reviewRatingView: CosmosView!
  @IBOutlet weak var reviewRatingLabel: UILabel!
  @IBOutlet weak var reviewCountLabel: UILabel!
  @IBOutlet weak var moreReviewButton: UIButton!
  
  @IBOutlet weak var reviewTableView: UITableView!
  @IBOutlet weak var reviewTableViewHeightConstraint: NSLayoutConstraint!
  
  
  
  //company
  @IBOutlet var companyBackView: UIView!
  @IBOutlet var companyThumbnail: UIImageView!
  @IBOutlet var companyTitle: UILabel!
  @IBOutlet var companyAverage: CosmosView!
  @IBOutlet var compnayAverageText: UILabel!
  @IBOutlet var companyLIkeCount: UILabel!
  
  
  
  var id: Int!
  
  var detailData: ThemaDetailData?
  
  var isWish: Bool = false
  var wishCount: Int = 0
  
  var themeImages: [Image] = []
  var themePriceList: [ThemePrice] = []
  
  var reviewList: [ThemeReview] = []
  
  var mainCollectionViewHeight: CGFloat = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBar.isHidden = false
    registDelegateDatasource()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.isNavigationBarHidden = false
    detailThema()
    themeReviewList()
  }
  
  func registDelegateDatasource() {
    mainCollectionView.delegate = self
    mainCollectionView.dataSource = self
    
    feeTableView.delegate = self
    feeTableView.dataSource = self
    
    reviewTableView.delegate = self
    reviewTableView.dataSource = self
    
    reviewTableView.estimatedRowHeight = 150
  }
  
  func initLevelStackView(_ level: Int) {
    let hiddenCount = 5 - level
    
    for i in 0..<level {
      levelStackView.arrangedSubviews[i].isHidden = false
    }
    
    for i in 0..<hiddenCount {
      levelStackView.arrangedSubviews[4-i].isHidden = true
    }
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
  
    func didGoUserReview(_ index: IndexPath) {
      let vc = UIStoryboard.init(name: "My", bundle: nil).instantiateViewController(withIdentifier: "MyReviewListVC") as! MyReviewListVC
      vc.isOther = true
      vc.userName = reviewList[index.row].userName
      self.navigationController?.pushViewController(vc, animated: true)
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
              self.detailThema()
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
    
  
  
  func initWithThemeDetailData(_ data: ThemaDetailData) {
    if data.thumbnail != nil {
      KingfisherManager.shared.retrieveImage(with: URL(string: data.thumbnail ?? "")!) { result in
        switch result {
          case .success(let value):
            let image = value.image.resizeToWidth(newWidth: self.view.frame.width)
            self.mainCollectionViewHeight = image.size.height
            self.mainCollectionViewHeightConstraint.constant = image.size.height
          case .failure:
            break
        }
      }
    }
    
    detailData = data
    imageLabelBackView.isHidden = true
    thumbnailView.isHidden = data.thumbnail == nil
    themeImages = [Image(id: 0, name: data.thumbnail ?? "")]
    imageCountLabel.text = "1/\(1)"
    
    priceView.isHidden = data.themePrices.count <= 0
    themePriceList = data.themePrices
    feeTableViewHeightConstraint.constant = CGFloat(data.themePrices.count * 40)
    
    isWish = data.isWish
    wishCount = data.wishCount
    wishBarButton.image = data.isWish ? UIImage(named: "isWishFull") : UIImage(named: "isWishEmpty")
    
    if data.typeNew == false {
      newImageView.isHidden = true
    } else {
      newImageView.isHidden = false
    }
    
    if data.typeDifferent == false {
      differentImageView.isHidden = true
    } else {
      differentImageView.isHidden = false
    }
    ratesView.settings.fillMode = .half
    reviewRatingView.settings.fillMode = .half
    
    titleLabel.text = "\(data.title)  \(data.category)"
    contentLabel.text = data.intro
    locationLabel.text = data.companyName
    ratesView.rating = data.grade
    
    reviewRatingView.rating = data.grade
    reviewRatingLabel.text = "\(data.grade)"

    wishScoreLabel.text = "\(data.wishCount)"
    
    initLevelStackView(data.level)
    
    timeLabel.text = "\(data.time)분"
    featureLabel.text = "활동성 \(data.activity) • 장치비율 \(data.tool) • \(data.recommendPerson)인 이상"
    
    mainCollectionView.reloadData()
    feeTableView.reloadData()
  }
  
  //   API
  func detailThema() {
    let apiurl = "/v1/theme/detail"
    
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiurl)")!
    let requestURL = url
      .appending("id", value: "\(id ?? 0)")
    
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
            self.intirx(companyId: value.data.companyId)
            self.detailCafe(id: value.data.companyId)
            self.initWithThemeDetailData(value.data)
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
    let apiurl = "/v1/themeReview/list"
    
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiurl)")!
    let requestURL = url
          .appending("limit", value: "2")
          .appending("page", value: "1")
      .appending("themeId", value: "\(id ?? 0)")
    
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
            self.reviewList.removeAll()
            self.reviewCountLabel.text = "\(value.list.count)"
              if value.list.count > 2 {
              self.moreReviewButton.isHidden = false
            } else {
              self.moreReviewButton.isHidden = true
            }
            self.reviewList = value.list.rows
            
            self.reviewTableView.reloadData()
            
            self.reviewTableView.layoutIfNeeded()
            self.reviewTableViewHeightConstraint.constant = self.reviewTableView.contentSize.height
          }
        }
        break
      case .failure:
        print("error: \(response.error!)")
        break
      }
    }
  }
  func detailCafe(id: Int) {
    let apiurl = "/v1/company/detail"
    
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiurl)")!
    let requestURL = url
      .appending("id", value: "\(id ?? 0)")
    
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
        
        if let data = jsonData, let value = try? decoder.decode(CompanyDetailResponse.self, from: data) {
          if value.statusCode == 200 {
            self.companyThumbnail.kf.setImage(with: URL(string: value.data.thumbnail ?? ""))
            self.companyTitle.text = value.data.title
            self.companyAverage.rating = value.data.averageRate
            self.compnayAverageText.text = "\(value.data.averageRate) (\(value.data.reviewCount))"
            self.companyLIkeCount.text = "(\(value.data.wishCount)"
          }
        }
        break
      case .failure:
        print("error: \(response.error!)")
        break
      }
    }
  }
  
  
  @IBAction func tapWish(_ sender: Any) {
    if DataHelperTool.token == nil {
      callYesNoMSGDialog(message: "로그인이 필요한 기능입니다.\n로그인 하시겠습니까?") {
        self.moveToLogin()
      }
    } else {
      
      let isWish = isWish ? false : true
      themeWish(id!, isWish) { value in
        if value.statusCode <= 201 {
          self.isWish = isWish
          self.wishCount = isWish ? self.wishCount + 1 : self.wishCount - 1
          self.wishScoreLabel.text = "\(self.wishCount)"
          self.wishBarButton.image = self.isWish ? UIImage(named: "isWishFull") : UIImage(named: "isWishEmpty")
        }
      }
    }
  }
  
  @IBAction func tapCall(_ sender: UIButton) {
    if let url = URL(string: "tel:\(detailData?.companyTel ?? "")") {
        UIApplication.shared.open(url, options: [:])
    }
  }
  
  @IBAction func tapReservation(_ sender: UIButton) {
    if let url = URL(string: "\(detailData?.companyHomepage ?? "")") {
        UIApplication.shared.open(url, options: [:])
    }
  }
  func intirx(companyId: Int){
      companyBackView.rx.tapGesture().when(.recognized)
        .bind(onNext: { [weak self] _ in
          let vc = UIStoryboard.init(name: "Cafe", bundle: nil).instantiateViewController(withIdentifier: "cafeDetail") as! CafeDetailVC
          vc.id = companyId
          self?.navigationController?.pushViewController(vc, animated: true)
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
  
  @IBAction func tapMoreReview(_ sender: UIButton) {
    let vc = UIStoryboard.init(name: "Thema", bundle: nil).instantiateViewController(withIdentifier: "themeReview") as! ThemeReviewVC
    vc.detailData = detailData
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
}

//MARK: - Extension
extension DetailThemaVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    if scrollView.isEqual(mainCollectionView) {
      let page = Int(targetContentOffset.pointee.x / mainCollectionView.bounds.width)
      print(page)
      imageCountLabel.text = "\(page + 1)/\(themeImages.count)"
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return themeImages.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: "mainImagesCell", for: indexPath) as! MainCell
    let dict = themeImages[indexPath.row]
    cell.mainImageView.kf.setImage(with: URL(string: dict.name))
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let size = mainCollectionView.layer.bounds.size
    return CGSize(width: size.width, height: self.mainCollectionViewHeight)
  }
}

extension DetailThemaVC: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if feeTableView == tableView {
      return themePriceList.count
    } else {
      return reviewList.count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if feeTableView == tableView {
      let cell = feeTableView.dequeueReusableCell(withIdentifier: "feeCell", for: indexPath) as! FeeCell
      let dict = themePriceList[indexPath.row]
      cell.initWithThemePrice(dict)
      
      cell.selectionStyle = .none
      
      return cell
    } else {
      let cell = reviewTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ReviewCell
      let dict = reviewList[indexPath.row]
        cell.delegate = self
      cell.initWithThemeReview(dict,indexPath)
      
      cell.lineView.isHidden = indexPath.row == (reviewList.count - 1)
      cell.isMineView.isHidden = (DataHelperTool.userAppId ?? 0) != dict.userId
      
      cell.selectionStyle = .none
      
      return cell
    }
    
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if feeTableView == tableView {
      return 40
    } else {
      return UITableView.automaticDimension
    }
  }
  
}

 
