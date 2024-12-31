//
//  MapVC.swift
//  roomEscape_re
//
//  Created by 이남기 on 2022/06/01.
//

import Foundation
import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import KakaoMapsSDK

public struct Place: Codable {
  let placeName :String
  let roadAdressName:String
  let longitudeX:String
  let latitudeY:String
}

protocol CompanySelectDelegate {
  func selectCompany(id: Int, name: String)
}

class MapVC: BaseViewController, UITextFieldDelegate, MapControllerDelegate{
  
  
  @IBOutlet var mapView: KMViewContainer!
  
  @IBOutlet weak var infoView: UIView!
  @IBOutlet weak var infoViewHeight: NSLayoutConstraint!
  
  @IBOutlet weak var shadowView: UIView!
  @IBOutlet weak var thumbnailImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var rateAndReviewCountLabel: UILabel!
  @IBOutlet weak var likeCountLabel: UILabel!
  
  var delegate: CompanySelectDelegate?
  
  var isCommunityRegist: Bool = false
  
  var CompanyList: [CompanyListData] = []
  var selectedCampsiteInfo: (Int, String)?
  
  var currentLatitude : Double =  currentLocation!.0
  var currentLongtitude : Double =  currentLocation!.1
  
  var resultList = [Place]()
  var mapController: KMController?
  var _auth = false
  var kakaoMap: KakaoMap?
  
  override func viewWillAppear(_ animated: Bool) {
      if _auth {
          if mapController?.isEngineActive == false {
              mapController?.activateEngine()
          }
      }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBar.isHidden = false
    shadowView.layer.applySketchShadow(color: .black, alpha: 0.16, x: 0, y: 1.5, blur: 3, spread: 0)
    shadowView.cornerRadius = 17.5
    initMap()
    
  }
  func addViews() {
      // MapviewInfo생성.
      // viewName과 사용할 viewInfoName, defaultPosition과 level을 설정한다.
      let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: MapPoint(longitude: currentLongtitude, latitude: currentLatitude), defaultLevel: 18)
          
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
      kakaoMap!.eventDelegate = self
      initMapLayer()
      initMarkers(-1,currentLongtitude, currentLatitude,true)
      initCafeList()
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
  
  func initMarkers(_ id : Int,_ longtitude: Double, _ latitude: Double, _ isCurrent: Bool) {
      let manager = kakaoMap?.getLabelManager()
      let layer = manager?.getLabelLayer(layerID: "PoiLayer")
      
      // 고유한 StyleID 생성
      let styleID = isCurrent ? "CurrentLocationStyle" : "DefaultStyle"
      let iconImage = UIImage(named: isCurrent ? "myLocationMarker" : "noneProfile")?.resizeToWidth(newWidth: 20)
      let iconStyle = PoiIconStyle(symbol: iconImage, anchorPoint: CGPoint(x: 0.0, y: 0.5))
      let perLevelStyle = PerLevelPoiStyle(iconStyle: iconStyle, level: 0)
      let poiStyle = PoiStyle(styleID: styleID, styles: [perLevelStyle])
      manager?.addPoiStyle(poiStyle)
      
      let poi = MapPoint(longitude: longtitude, latitude: latitude)
      let poiOption = PoiOptions(styleID: styleID,poiID: "\(id)")
      poiOption.rank = 0
      poiOption.clickable = true
      
      // Poi 생성 및 스타일 적용
      let poi1 = layer?.addPoi(option: poiOption, at: poi) // 스타일 변경 강제 반영
      let _ = poi1?.addPoiTappedEventHandler(target: self, handler: MapVC.poiTappedHandler) // poi tap

      poi1?.show()
  }
  
  func poiTappedHandler(_ param: PoiInteractionEventParam) {
        if param.poiItem.itemID != "-1" {
          let dict = CompanyList.filter { $0.id == Int(param.poiItem.itemID) }
          initWithCompanyListData(dict.first!)
    
          UIView.animate(withDuration: 0.2) {
            self.infoViewHeight.constant = 95
            self.infoView.isHidden = false
            self.view.layoutIfNeeded()
          }
        }
    
  }
  
  func setLocationWithAddress(_ keyword: String) {
    let headers: HTTPHeaders = [
      "Authorization": "KakaoAK b5daee598da0fca2273a2ac238665aee"
    ]
    
    let parameters: [String: Any] = [
      "query": keyword
    ]
    
    AF.request("https://dapi.kakao.com/v2/local/search/keyword.json", method: .get,
               parameters: parameters, headers: headers)
      .responseJSON(completionHandler: { response in
        print(response)
        switch response.result {
        case .success(let value):
          self.resultList.removeAll()
          
          if let detailsPlace = JSON(value)["documents"].array{
            for item in detailsPlace{
              let placeName = item["place_name"].string ?? ""
              let roadAdressName = item["road_address_name"].string ?? ""
              let longitudeX = item["x"].string ?? ""
              let latitudeY = item["y"].string ?? ""
              self.resultList.append(Place(placeName: placeName,
                                           roadAdressName: roadAdressName, longitudeX: longitudeX, latitudeY: latitudeY))
            }
            
          }
          if self.resultList.count > 0 {
            print("\(self.resultList[0].placeName)")
            print("위도: \(self.resultList[0].latitudeY)\n경도: \(self.resultList[0].longitudeX)")
          } else {
            self.callMSGDialog(message: "검색 결과가 없습니다")
          }
          
        case .failure(let error):
          print("error ; \(error)")
          self.callMSGDialog(message: "검색 결과가 없습니다")
        }
      })
  }
  
  func initWithCompanyListData(_ data: CompanyListData) {
    selectedCampsiteInfo = (data.id, data.title)
    
    thumbnailImageView.kf.setImage(with: URL(string:data.thumbnail!)!)
    
    nameLabel.text = data.title
    likeCountLabel.text = "\(data.wishCount)"
    
    
    let numberFormatter = NumberFormatter()
    numberFormatter.roundingMode = .floor         // 형식을 버림으로 지정
    numberFormatter.minimumSignificantDigits = 2
    numberFormatter.maximumSignificantDigits = 2
    let rate = numberFormatter.string(from: NSNumber(value: data.averageRate)) ?? "0.0"
    rateAndReviewCountLabel.text = "\(rate) (\(data.reviewCount))"
  }
  
  func initCafeList() {
    self.showHUD()
    let apiurl = "/v1/company/list"
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiurl)")!
    let requestURL = url
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
        if let data = jsonData, let value = try? decoder.decode(CompanyListResponse.self, from: data) {
          if value.statusCode == 200 {
            print("==========")
            self.CompanyList = value.list
            for(result) in value.list{
              self.initMarkers(result.id,Double(result.longitude!)!, Double(result.latitude!)!, false)
            }
            self.dismissHUD()
          } else {
            self.callMSGDialog(message: value.message)
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
  
  @IBAction func tapCafeInfo(_ sender: UIButton) {
    if selectedCampsiteInfo != nil {
      let vc = UIStoryboard.init(name: "Cafe", bundle: nil).instantiateViewController(withIdentifier: "cafeDetail") as! CafeDetailVC
      vc.id = selectedCampsiteInfo?.0 ?? 0
      self.goViewController(vc: vc)
    }
  }
  
  
  @IBAction func tapSelectCamp(_ sender: UIButton) {
    if selectedCampsiteInfo != nil {
      backPress()
      delegate?.selectCompany(id: selectedCampsiteInfo!.0, name: selectedCampsiteInfo!.1)
    }
    
  }
  
}
extension MapVC : KakaoMapEventDelegate{
  
  func poiDidTapped(_ poi: Poi) {
    print("poiDidTapped")
  }
  
  func kakaoMapdidTapped(_ poi: Poi) {
    print("kakaoDidTapped")
  }
  
  func kakaoMapFocusDidChanged (_ map: KakaoMap) {
    print("kakaoMapFocusDidChanged")
  }
  func terrainDidTapped(kakaoMap: KakaoMap, position: MapPoint) {
          let mapView: KakaoMap = mapController?.getView("mapview") as! KakaoMap
          let manager = mapView.getLabelManager()
          let layer = manager.getLabelLayer(layerID: "example_click_service")
          let option = PoiOptions(styleID: "label_default_style")
          option.clickable = true
          
          let poi = layer?.addPoi(option: option, at: position)
          poi?.show()
      }
  
}

// MARK: - MTMapViewDelegate

//extension MapVC: MTMapViewDelegate {
//  func mapView(_ mapView: MTMapView!, selectedPOIItem poiItem: MTMapPOIItem!) -> Bool {
//    return true
//  }
//  
//  func mapView(_ mapView: MTMapView!, singleTapOn mapPoint: MTMapPoint!) {
//    UIView.animate(withDuration: 0.2) {
//      self.infoViewHeight.constant = 0
//      self.infoView.isHidden = true
//      self.view.layoutIfNeeded()
//    }
//  }
//  //    func mapView(_ mapView: MTMapView!, dragEndedOn mapPoint: MTMapPoint!) {
//  //        currentLatitude = mapPoint.mapPointGeo().latitude
//  //        currentLongtitude = mapPoint.mapPointGeo().longitude
//  //        initCompanyList()
//  //    }
//  
//  func mapView(_ mapView: MTMapView!, dragStartedOn mapPoint: MTMapPoint!) {
//    UIView.animate(withDuration: 0.2) {
//      self.infoViewHeight.constant = 0
//      self.infoView.isHidden = true
//      self.view.layoutIfNeeded()
//    }
//  }
//  
//  func mapView(_ mapView: MTMapView!, touchedCalloutBalloonOf poiItem: MTMapPOIItem!) {
//    let dict = CompanyList[poiItem.tag]
//    let vc = UIStoryboard.init(name: "Cafe", bundle: nil).instantiateViewController(withIdentifier: "cafeDetail") as! CafeDetailVC
//    vc.id = dict.id
//    self.goViewController(vc: vc)
//  }
//}
