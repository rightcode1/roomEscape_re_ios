//
//  CafeDetailVC.swift
//  roomEscape_re
//
//  Created by hoon Kim on 2022/02/02.
//

import UIKit
import Alamofire
import SwiftyJSON
import Cosmos

class CafeDetailVC: BaseViewController, WishDelegate, ReviewCellMyButtonsDelegate {
  @IBOutlet weak var wishBarButton: UIBarButtonItem!
  
  @IBOutlet weak var thumbnailView: UIView!
  @IBOutlet weak var mainCollectionView: UICollectionView!
  
  @IBOutlet weak var imageCountLabel: UILabel!
  @IBOutlet weak var imageLabelBackView: UIView!
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var ratingView: CosmosView!
  @IBOutlet weak var ratingAndReviewCountLabel: UILabel!
  @IBOutlet weak var wishCountLabel: UILabel!
  @IBOutlet weak var contentLabel: UILabel!
  
  @IBOutlet weak var contentTableView: UITableView!
  @IBOutlet weak var contentTableViewHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet var locationMapView: MTMapView!
  @IBOutlet weak var addressLabel: UILabel!
  
  @IBOutlet weak var reviewRatingView: CosmosView!
  @IBOutlet weak var reviewRatingLabel: UILabel!
  @IBOutlet weak var reviewCountLabel: UILabel!
  @IBOutlet weak var moreReviewButton: UIButton!
  
  @IBOutlet weak var reviewTableView: UITableView!
  @IBOutlet weak var reviewTableViewHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet var copyAddressButton: UIImageView!
  
  var id: Int!
  
  var isWish: Bool = false
  var wishCount: Int = 0
  
  var homepageUrl: String?
  var tel: String?
  
  var cafeDetailData: CompanyDetailData!
  
  var cafeImages: [Image] = []
  
  var themeList: [ThemaListData] = []
  
  var reviewList: [CompanyReview] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBar.isHidden = false
    contentTableView.delegate = self
    contentTableView.dataSource = self
    
    reviewTableView.delegate = self
    reviewTableView.dataSource = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    print("\(currentLocation!.1)!!!!")
    detailCafe()
    initThemeList()
    companyReviewList()
  }
  
  func initWithCompanyDetailData(_ data: CompanyDetailData) {
    
    cafeDetailData = data
    
    thumbnailView.isHidden = data.companyImages.count <= 0
    cafeImages = data.companyImages
    imageCountLabel.text = "1/\(data.companyImages.count)"
    
    ratingView.settings.fillMode = .half
    reviewRatingView.settings.fillMode = .half

    titleLabel.text = data.title
    distanceLabel.text = "\(data.distance)km"
      ratingView.rating = data.averageRate
    reviewRatingView.rating = data.averageRate
    reviewRatingLabel.text = "\(String(format: "%.1f점", data.averageRate)) (\(data.reviewCount))"
    ratingAndReviewCountLabel.text = "\(String(format: "%.1f점", data.averageRate)) (\(data.reviewCount))"
    isWish = data.isWish
    wishCount = data.wishCount
    wishBarButton.image = data.isWish ? UIImage(named: "isWishFull") : UIImage(named: "isWishEmpty")
    
    homepageUrl = data.homepage
    tel = data.tel
    
    wishCountLabel.text = "\(data.wishCount)"
    contentLabel.text = data.intro
    
    let locationInfo = (Double(data.latitude) ?? 37.5057804, Double(data.longitude) ?? 127.0262161)
    let initialPointGeo = MTMapPointGeo(latitude: locationInfo.0,
                                        longitude: locationInfo.1)
    locationMapView.setMapCenter(MTMapPoint(geoCoord: initialPointGeo), animated: false)
    locationMapView.setZoomLevel(1, animated: false)
    var poiItems = [MTMapPOIItem]()
    
    let myPointItme = MTMapPOIItem()
    myPointItme.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: locationInfo.0, longitude: locationInfo.1))
    myPointItme.markerType = MTMapPOIItemMarkerType.customImage
    myPointItme.tag = -1
    
    myPointItme.customImage = #imageLiteral(resourceName: "myLocationMarker").resizeToWidth(newWidth: 25)
    
    poiItems.append(myPointItme)
    
    locationMapView.addPOIItems(poiItems)
    addressLabel.text = data.address
    
    mainCollectionView.reloadData()
  }
  
  func detailCafe() {
    let apiurl = "/v1/company/detail"
    
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiurl)")!
    let requestURL = url
      .appending("id", value: "\(id ?? 0)")
      .appending("latitude", value: "\(currentLocation!.0)")
      .appending("longitude", value: "\(currentLocation!.1)")
    
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
            self.initWithCompanyDetailData(value.data)
          }
        }
        break
      case .failure:
        print("error: \(response.error!)")
        break
      }
    }
  }
  
  
  func initThemeList() {
    let apiurl = "/v1/theme/list"
    
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiurl)")!
    let requestURL = url
      .appending("companyId", value: "\(id ?? 0)")
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
            self.contentTableView.reloadData()
            self.contentTableViewHeightConstraint.constant = CGFloat((self.themeList.count * 210))
          }
        }
        break
      case .failure:
        
        print("error: \(response.error!)")
        break
      }
    }
  }
  
  func companyReviewList() {
    let apiurl = "/v1/companyReview/list"
    
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiurl)")!
    let requestURL = url
      .appending("page", value: "1")
      .appending("limit", value: "3")
      .appending("companyId", value: "\(id ?? 0)")
    
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
        
        if let data = jsonData, let value = try? decoder.decode(CompanyRowReviewResponse.self, from: data) {
          if value.statusCode == 200 {
            self.reviewList.removeAll()
            
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
        
        if let data = jsonData, let value = try? decoder.decode(DefaultResponse.self, from: data) {
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
  func initrx(){
    copyAddressButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        UIPasteboard.general.string = self?.cafeDetailData.address
        self?.showToast(message: "클립보드에 복사되었습니다.")
      })
      .disposed(by: disposeBag)
  }
  
  @IBAction func tapWish(_ sender: Any) {
    if DataHelperTool.token == nil {
      callYesNoMSGDialog(message: "로그인이 필요한 기능입니다.\n로그인 하시겠습니까?") {
        self.moveToLogin()
      }
    } else {
      let isWish = isWish ? false : true
      cafeWish(id!, isWish) { value in
        if value.statusCode <= 201 {
          self.isWish = isWish
          self.wishCount = isWish ? self.wishCount + 1 : self.wishCount - 1
          self.wishCountLabel.text = "\(self.wishCount)"
          self.wishBarButton.image = self.isWish ? UIImage(named: "isWishFull") : UIImage(named: "isWishEmpty")
        }
      }
    }
  }
  
  @IBAction func tapMoveHomepage(_ sender: UIButton) {
    if let url = URL(string: homepageUrl ?? "") {
        UIApplication.shared.open(url, options: [:])
    }
  }
  
  @IBAction func tapCall(_ sender: UIButton) {
    if let url = URL(string: "tel:\(tel ?? "")") {
        UIApplication.shared.open(url, options: [:])
    }
  }
  
  @IBAction func tapRegistReview(_ sender: UIButton) {
    let vc = UIStoryboard.init(name: "Cafe", bundle: nil).instantiateViewController(withIdentifier: "registCafeReview") as! RegistCafeReviewVC
    vc.companyId = cafeDetailData.id
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  @IBAction func tapMoreReview(_ sender: UIButton) {
    let vc = UIStoryboard.init(name: "Cafe", bundle: nil).instantiateViewController(withIdentifier: "cafeReview") as! CafeReviewVC
    vc.cafeDetailData = cafeDetailData
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
  
}
//MARK: - Extension
extension CafeDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    if scrollView.isEqual(mainCollectionView) {
      let page = Int(targetContentOffset.pointee.x / mainCollectionView.bounds.width)
      print(page)
      imageCountLabel.text = "\(page + 1)/\(cafeImages.count)"
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return cafeImages.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: "mainImagesCell", for: indexPath) as! MainCell
    let dict = cafeImages[indexPath.row]
    cell.mainImageView.kf.setImage(with: URL(string: dict.name))
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let size = mainCollectionView.bounds.size
    return CGSize(width: size.width, height: size.height)
  }
  
}
extension CafeDetailVC: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if contentTableView == tableView {
      return themeList.count
    } else {
      return reviewList.count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if contentTableView == tableView {
      let cell = contentTableView.dequeueReusableCell(withIdentifier: "contentTableViewCell", for: indexPath) as! ContentCell
      let dict = themeList[indexPath.row]
      cell.initContentList(dict)
      
      cell.delegate = self
      cell.index = indexPath.row
      
      cell.selectionStyle = .none
      
      return cell
    } else {
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
    
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if contentTableView == tableView {
      let dict = themeList[indexPath.row]
      let vc = UIStoryboard.init(name: "Thema", bundle: nil).instantiateViewController(withIdentifier: "DetailThemaVC") as! DetailThemaVC
      vc.id = dict.id
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if contentTableView == tableView {
      return 210
    } else {
      return UITableView.automaticDimension
    }
  }
  
}

 
