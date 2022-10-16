//
//  HomeVC.swift
//  escapeRoom
//
//  Created by RightCode_IOS on 2021/12/05.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import Cosmos
import Kingfisher

class HomeVC: BaseViewController {
  
  @IBOutlet weak var categoryCollectionView: UICollectionView!
  @IBOutlet weak var bannerCollectionView: UICollectionView!
  @IBOutlet weak var recommendThemeCollectionView: UICollectionView!
  @IBOutlet weak var recommendCafeCollectionView: UICollectionView!
  
  @IBOutlet weak var searchBarView: UIView!
  @IBOutlet weak var favoritesView: UIView!
  @IBOutlet weak var categoryView: UIView!
  
  @IBOutlet weak var recommendThemeCollectionViewHeight: NSLayoutConstraint!
  
  @IBOutlet weak var bannerCountLabel: UILabel!
  @IBOutlet weak var bannerCountBackView: UIView!
  
  var categoryImageArray: [(UIImage, String)] = [
    (UIImage(named: "gangnam")!, "강남"),
    (UIImage(named: "hongdae")!, "홍대"),
    (UIImage(named: "sinchon")!, "신촌"),
    (UIImage(named: "gundae")!, "건대"),
    (UIImage(named: "daehakro")!, "대학로"),
    (UIImage(named: "new")!, "new"),
    (UIImage(named: "easy")!, "easy"),
    (UIImage(named: "hard")!, "hard"),
    (UIImage(named: "horror")!, "공포"),
    (UIImage(named: "adult")!, "19금"),
    (UIImage(named: "different")!, "different"),
    (UIImage(named: "map")!, "map"),
    (UIImage(named: "community")!, "community"),
    (UIImage(named: "event")!, "event"),
    (UIImage(named: "qanda")!, "qanda")
  ]
  
  let manager = CLLocationManager()
  
  var nowPage: Int = 0
  var bannerList: [AdvertisementData] = []
  
  var themeList: [ThemaListData] = []
  
  var cafeList: [CompanyListData] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    categoryCollectionView.delegate = self
    categoryCollectionView.dataSource = self
    
    bannerCollectionView.delegate = self
    bannerCollectionView.dataSource = self
    
    recommendThemeCollectionView.delegate = self
    recommendThemeCollectionView.dataSource = self
    
    recommendCafeCollectionView.delegate = self
    recommendCafeCollectionView.dataSource = self
    
    recommendThema()
    recommendCafe()
    //     3번쨰 콜렉션뷰 높이
    initRecommendThemeCollecitonViewHeight()
    
    initLayoutViews()
    
    initBannerAdvertisement()
    setMyLocation()
    initrx()
  }
  
  func setMyLocation() {
    manager.delegate = self
    manager.desiredAccuracy = kCLLocationAccuracyBest
    let status = CLLocationManager.authorizationStatus()
    if status == .notDetermined {
      manager.requestWhenInUseAuthorization()
    } else if status == .restricted || status == .denied {
      //        self.addressLabel.text = "전체지역"
    } else {
      manager.startUpdatingLocation()
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.navigationBar.isHidden = true
  }
  override func viewWillDisappear(_ animated: Bool) {
    bannerTimer("stop")
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func initLayoutViews() {
    searchBarView.layer.cornerRadius = 15
    favoritesView.layer.cornerRadius = 7.5
    
    bannerCountBackView.backgroundColor = UIColor(red: 101/255, green: 101/255, blue: 101/255, alpha: 0.68)
    bannerCountBackView.layer.cornerRadius = 9
    
    categoryView.layer.cornerRadius = 10
    categoryView.layer.borderWidth = 0.5
    categoryView.layer.borderColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0).cgColor
  }
  
  func initRecommendThemeCollecitonViewHeight() {
    let phoneWidth = UIScreen.main.bounds.width
    let photo = (phoneWidth - 30) / 3
    let diff = photo / 107
    let height = diff * 222
    
    recommendThemeCollectionViewHeight.constant = height
  }
  
  func bannerTimer(_ status:String) {
    if !bannerList.isEmpty{
      var timer: Timer? = nil
      if(status == "go"){
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (Timer) in
          self.bannerMove()
        }
      }else{
        timer?.invalidate()
        timer = nil
      }
    }
  }
  
  func bannerMove() {
    if nowPage == bannerList.count-1 {
      bannerCollectionView.scrollToItem(at: NSIndexPath(item: 0, section: 0) as IndexPath, at: .right, animated: true)
      nowPage = 0
      return
    }
    nowPage += 1
    bannerCountLabel.text = "\(nowPage+1)/\(bannerList.count)"
    bannerCollectionView.scrollToItem(at: NSIndexPath(item: nowPage, section: 0) as IndexPath, at: .left, animated: true)
  }
  
  func recommendThema() {
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
            self.recommendThemeCollectionView.reloadData()
            
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
  
  func recommendCafe() {
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
            self.recommendCafeCollectionView.reloadData()
            self.bannerCollectionView.reloadData()
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
  
  func initBannerAdvertisement() {
    let apiUrl = "/v1/advertisement/list"
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiUrl)")!
    let requestURL = url
      .appending("location", value: "메인배너")
    var request = URLRequest(url: requestURL)
    
    request.httpMethod = HTTPMethod.get.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("\(DataHelperTool.token ?? "")", forHTTPHeaderField: "Authorization")
    //    request.httpBody = try! JSONSerialization.data(withJSONObject: param.dictionary ?? [:], options: .prettyPrinted)
    
    AF.request(request).responseJSON { (response) in
      switch response.result {
      case .success(let value):
        let decoder = JSONDecoder()
        let json = JSON(value)
        let jsonData = try? json.rawData()
        
        print("\(apiUrl) responseJson: \(json)")
        
        if let data = jsonData, let value = try? decoder.decode(AdvertisementListResponse.self, from: data) {
          if value.statusCode == 200 {
            self.bannerList.removeAll()
            self.bannerList = value.list
            self.bannerCollectionView.reloadData()
            self.bannerTimer("go")
          } else {
            self.callMSGDialog(message: value.message)
          }
        }
        break
      case .failure:
        self.dismissHUD()
        print("\(apiUrl) error: \(response.error!)")
        break
      }
    }
  }
  func initrx(){
    searchBarView.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        let vc = UIStoryboard.init(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "search") as! SearchVC
        self?.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)
  }
  
  @IBAction func tapWish(_ sender: UIButton) {
    let vc = UIStoryboard.init(name: "My", bundle: nil).instantiateViewController(withIdentifier: "wishList") as! WishListVC
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  @IBAction func tapMoreTheme(_ sender: UIButton) {
    selectedAddressFromHomeVC = "추천테마"
    tabBarController?.selectedIndex = 1
  }
  
  @IBAction func tapMoreCafe(_ sender: UIButton) {
    selectedAddressFromCafeVC = "추천카페"
    tabBarController?.selectedIndex = 0
  }
  
}


extension HomeVC: UICollectionViewDataSource, UICollectionViewDelegate {
  
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    
    if scrollView.isEqual(bannerCollectionView) {
      nowPage = Int(targetContentOffset.pointee.x / (self.bannerCollectionView.frame.width))
      bannerCountLabel.text = "\(nowPage+1)/\(bannerList.count)"
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    if collectionView == self.categoryCollectionView {
      return categoryImageArray.count
    } else if collectionView == self.bannerCollectionView {
      return bannerList.count
    } else if collectionView == self.recommendThemeCollectionView {
      return themeList.count
    } else {
      return cafeList.count
    }
    
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    if collectionView == self.categoryCollectionView {
      let cellA = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategoryCell
      
      cellA.categoryImageView.image = categoryImageArray[indexPath.item].0
      
      return cellA
    } else if collectionView == self.bannerCollectionView {
      let cellB = collectionView.dequeueReusableCell(withReuseIdentifier: "bannerCell", for: indexPath) as! BannerCell
      let diff = bannerList[indexPath.row]
      cellB.bannerImageView.kf.setImage(with: URL(string: diff.thumbnail ?? ""))
      
      return cellB
    } else if collectionView == self.recommendThemeCollectionView {
      let cellC = collectionView.dequeueReusableCell(withReuseIdentifier: "recommendThemaCell", for: indexPath) as! RecommendThemaCell
      
      let dict = themeList[indexPath.row]
      cellC.initWithOrderCountData(dict)
      
      return cellC
    } else {
      let cellD = collectionView.dequeueReusableCell(withReuseIdentifier: "recommendCafeCell", for: indexPath) as! RecommendCafeCell
      
      let dict = cafeList[indexPath.row]
      cellD.initWithOrderCountData(dict)
      
      return cellD
    }
  }
}

extension HomeVC: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:
                      UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    if collectionView == categoryCollectionView {
      let phoneWidth = UIScreen.main.bounds.width
      let categorySize = (phoneWidth - 56) / 5
      let diff = categorySize / 61
      let height = diff * 50
      
      return CGSize(width: categorySize, height: height)
    }
    else if collectionView == bannerCollectionView {
      let phoneWidth = APP_WIDTH()
      let bannerSize = (phoneWidth - 30)
      let diff = bannerSize / 720 * 250
      let height = diff
      
      return CGSize(width: bannerSize, height: height)
    }
    else if collectionView ==  recommendThemeCollectionView {
      
      let phoneWidth = UIScreen.main.bounds.width
      let photo = (phoneWidth - 30) / 3
      let diff = photo / 107
      let height = diff * 222
      
      return CGSize(width: photo, height: height)
    } else {
      let phoneWidth = UIScreen.main.bounds.width
      let photo = (phoneWidth - 30) / 1.6
      let diff = photo / 242
      let height = diff * 168
      
      return CGSize(width: photo, height: height)
      
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if collectionView == bannerCollectionView {
      print("indexPath.row : \(indexPath.row)")
      let dict = bannerList[indexPath.row]
      if dict.diff.contains(find: "url") {
        if let url = URL(string: dict.url ?? "") {
          if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
          }
        }
      } else {
        let vc = UIStoryboard.init(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "advertisement") as! AdvertisementViewController
        vc.imageURL = dict.image
      vc.diff = "메인배너"
      vc.url = dict.url
        self.navigationController?.pushViewController(vc, animated: true)
      }
    }
    
    if categoryCollectionView == collectionView {
      let dict = categoryImageArray[indexPath.row]
        if(dict.1 == "qanda"){
            if let url = URL(string: "http://pf.kakao.com/_JxmVGb/chat") {
              UIApplication.shared.open(url, options: [:])
            }
        }else if(dict.1 == "map"){
          let vc = UIStoryboard.init(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "MapVC") as! MapVC
          self.navigationController?.pushViewController(vc, animated: true)
        }else if(dict.1 == "community"){
            tabBarController?.selectedIndex = 3
        }else if(dict.1 == "event"){
              let vc = UIStoryboard.init(name: "My", bundle: nil).instantiateViewController(withIdentifier: "EventVC") as! EventVC
              self.navigationController?.pushViewController(vc, animated: true)
        }else if(dict.1 == "different"){
            selectedAddressFromCafeVC = dict.1
            tabBarController?.selectedIndex = 0
        }else{
          selectedAddressFromHomeVC = dict.1
          tabBarController?.selectedIndex = 1
        }
    }
    
    if recommendThemeCollectionView == collectionView {
      let dict = themeList[indexPath.row]
      let vc = UIStoryboard.init(name: "Thema", bundle: nil).instantiateViewController(withIdentifier: "DetailThemaVC") as! DetailThemaVC
      vc.id = dict.id
      self.navigationController?.pushViewController(vc, animated: true)
    }
    
    if recommendCafeCollectionView == collectionView {
      let dict = cafeList[indexPath.row]
      
      let vc = UIStoryboard.init(name: "Cafe", bundle: nil).instantiateViewController(withIdentifier: "cafeDetail") as! CafeDetailVC
      vc.id = dict.id
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }
}
extension HomeVC: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == .restricted || status == .denied {
      
    } else {
      manager.startUpdatingLocation()
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    //위치가 업데이트될때마다
    if let location = manager.location {
      print("latitude :" + String(location.coordinate.latitude) + " / longitude :" + String(location.coordinate.longitude))
      currentLocation = (location.coordinate.latitude, location.coordinate.longitude)
      manager.stopUpdatingLocation()
      
      let geoCoder = CLGeocoder()
      geoCoder.reverseGeocodeLocation(location) { (placemarks, error) -> Void in
        if let error = error {
          NSLog("\(error)")
          return
        }
      }
    }
  }
  
}


