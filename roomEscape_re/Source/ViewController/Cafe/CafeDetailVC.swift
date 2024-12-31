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
import KakaoMapsSDK

class CafeDetailVC: BaseViewController, WishDelegate, ReviewCellMyButtonsDelegate, MapControllerDelegate {
  
  
  @IBOutlet var mapView: KMViewContainer!
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
  var mapController: KMController?
  var _auth = false
  var kakaoMap: KakaoMap?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    DataHelper<Any>.appendAdCount()
    navigationController?.navigationBar.isHidden = false
    contentTableView.delegate = self
    contentTableView.dataSource = self
    
    reviewTableView.delegate = self
    reviewTableView.dataSource = self
    initrx()
  }
  
  override func viewWillAppear(_ animated: Bool) {
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
    addressLabel.text = data.address
    
    mainCollectionView.reloadData()
  }
  
  func addViews() {
      // MapviewInfo생성.
      // viewName과 사용할 viewInfoName, defaultPosition과 level을 설정한다.
      let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: MapPoint(longitude: Double(cafeDetailData.longitude)!, latitude: Double(cafeDetailData.latitude)!), defaultLevel: 18)
          
      // mapviewInfo를 파라미터로 mapController를 통해 생성한 뷰의 객체를 얻어온다.
      // 정상적으로 생성되면 MapControllerDelegate의 addViewSucceeded가 호출되고, 실패하면 addViewFailed가 호출된다.
      mapController?.addView(mapviewInfo)
  }

  //addView 성공 이벤트 delegate. 추가적으로 수행할 작업을 진행한다.
  func addViewSucceeded(_ viewName: String, viewInfoName: String) {
      print("OK") //추가 성공. 성공시 추가적으로 수행할 작업을 진행한다.
    _auth = true
    // 여기에서만 getView 호출
    if let view = mapController?.getView(viewName) as? KakaoMap {
      kakaoMap = view
      initMapLayer()
      self.initMarkers(Double(cafeDetailData.longitude)!, Double(cafeDetailData.latitude)!)
    } else {
        print("Failed to get map view.")
    }
  }

  //addView 실패 이벤트 delegate. 실패에 대한 오류 처리를 진행한다.
  func addViewFailed(_ viewName: String, viewInfoName: String) {
      print("Failed")
  }
  
  // MapControllerDelegate. 인증에 성공했을 경우 호출.
  func authenticationSucceeded() {
    mapController?.activateEngine()
  }
  
  func authenticationFailed(_ errorCode: Int, desc: String) {
      print("error code: \(errorCode)")
      print("\(desc)")

      // 추가 실패 처리 작업
      mapController?.prepareEngine() //인증 재시도
  }
  
  func initMap() {
    mapController = KMController(viewContainer: mapView)
    mapController!.delegate = self
    mapController?.prepareEngine() //엔진 prepare
  }
  
  func initMapLayer(){
    let manager = kakaoMap!.getLabelManager()
    let layerOption = LabelLayerOptions(layerID: "PoiLayer", competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 0)
    manager.addLabelLayer(option: layerOption)
  }
  
  func initMarkers(_ longtitude: Double, _ latitude: Double) {
      let manager = kakaoMap?.getLabelManager()
      let layer = manager?.getLabelLayer(layerID: "PoiLayer")
      
      // 고유한 StyleID 생성
      let iconImage = UIImage(named: "myLocationMarker")?.resizeToWidth(newWidth: 20)
      let iconStyle = PoiIconStyle(symbol: iconImage, anchorPoint: CGPoint(x: 0.0, y: 0.5))
      let perLevelStyle = PerLevelPoiStyle(iconStyle: iconStyle, level: 0)
      let poiStyle = PoiStyle(styleID: "CurrentLocationStyle", styles: [perLevelStyle])
      manager?.addPoiStyle(poiStyle)
      
      let poi = MapPoint(longitude: longtitude, latitude: latitude)
      let poiOption = PoiOptions(styleID: "CurrentLocationStyle",poiID: "\(id)")
      poiOption.rank = 0
      
      // Poi 생성 및 스타일 적용
      let poi1 = layer?.addPoi(option: poiOption, at: poi) // 스타일 변경 강제 반영

      poi1?.show()

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
            self.initMap()
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
  func didReportUser(_ reviewId: Int, _ index: IndexPath) {
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
  func didGoUserReview(_ index: IndexPath) {
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
      self.goViewController(vc: vc)
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

 
