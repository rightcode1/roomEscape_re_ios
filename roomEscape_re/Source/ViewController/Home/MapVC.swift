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

public struct Place: Codable {
  let placeName :String
  let roadAdressName:String
  let longitudeX:String
  let latitudeY:String
}

protocol CompanySelectDelegate {
  func selectCompany(id: Int, name: String)
}

class MapVC: UIViewController, UITextFieldDelegate {
  
  @IBOutlet var mapView: MTMapView! {
    didSet {
      mapView.delegate = self
    }
  }
  
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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBar.isHidden = false
    shadowView.layer.applySketchShadow(color: .black, alpha: 0.16, x: 0, y: 1.5, blur: 3, spread: 0)
    shadowView.cornerRadius = 17.5
    
    let initialPointGeo = MTMapPointGeo(latitude: currentLocation!.0,
                                        longitude:  currentLocation!.1)
    mapView.setMapCenter(MTMapPoint(geoCoord: initialPointGeo), animated: true)
    mapView.setZoomLevel(MTMapZoomLevel(1), animated: true)
    
    initCafeList()
  }
  
  func initMarkers(_ list: [CompanyListData]) {
    print("===============\(list)")
    DispatchQueue.global().sync {
      self.mapView.removeAllPOIItems()
      var poiItems = [MTMapPOIItem]()
      poiItems.removeAll()
      
      self.CompanyList = list
      
      for (index, list) in list.enumerated() {
        let pointItme = MTMapPOIItem()
        pointItme.itemName = list.title
        
        pointItme.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: Double(list.latitude ?? "")!, longitude: Double(list.longitude ?? "")!))
        pointItme.markerType = MTMapPOIItemMarkerType.customImage
        
        pointItme.customImage = #imageLiteral(resourceName: "noneProfile").resizeToWidth(newWidth: 35)
        
        pointItme.tag = index
        
        poiItems.append(pointItme)
      }
      
      let myPointItme = MTMapPOIItem()
      myPointItme.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: currentLocation!.0, longitude: currentLocation!.1))
      myPointItme.markerType = MTMapPOIItemMarkerType.customImage
      myPointItme.tag = -1
      
      myPointItme.customImage = #imageLiteral(resourceName: "myLocationMarker").resizeToWidth(newWidth: 25)
      
      poiItems.append(myPointItme)
      
      self.mapView.addPOIItems(poiItems)
      
      DispatchQueue.main.async {
        self.mapView.reloadInputViews()
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
            
            let initialPointGeo = MTMapPointGeo(latitude: Double(self.resultList[0].latitudeY)!,
                                                longitude:  Double(self.resultList[0].longitudeX)!)
            
            self.mapView.setMapCenter(MTMapPoint(geoCoord: initialPointGeo), animated: false)
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
            self.initMarkers(value.list)
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
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }
  
  
  @IBAction func tapSelectCamp(_ sender: UIButton) {
    if selectedCampsiteInfo != nil {
      backPress()
      delegate?.selectCompany(id: selectedCampsiteInfo!.0, name: selectedCampsiteInfo!.1)
    }
    
  }
  
}

// MARK: - MTMapViewDelegate

extension MapVC: MTMapViewDelegate {
  func mapView(_ mapView: MTMapView!, selectedPOIItem poiItem: MTMapPOIItem!) -> Bool {
    if poiItem.tag != -1 {
      let dict = CompanyList[poiItem.tag]
      initWithCompanyListData(dict)
      
      UIView.animate(withDuration: 0.2) {
        self.infoViewHeight.constant = 95
        self.infoView.isHidden = false
        self.view.layoutIfNeeded()
      }
    }
    
    return true
  }
  
  func mapView(_ mapView: MTMapView!, singleTapOn mapPoint: MTMapPoint!) {
    UIView.animate(withDuration: 0.2) {
      self.infoViewHeight.constant = 0
      self.infoView.isHidden = true
      self.view.layoutIfNeeded()
    }
  }
  //    func mapView(_ mapView: MTMapView!, dragEndedOn mapPoint: MTMapPoint!) {
  //        currentLatitude = mapPoint.mapPointGeo().latitude
  //        currentLongtitude = mapPoint.mapPointGeo().longitude
  //        initCompanyList()
  //    }
  
  func mapView(_ mapView: MTMapView!, dragStartedOn mapPoint: MTMapPoint!) {
    UIView.animate(withDuration: 0.2) {
      self.infoViewHeight.constant = 0
      self.infoView.isHidden = true
      self.view.layoutIfNeeded()
    }
  }
  
  func mapView(_ mapView: MTMapView!, touchedCalloutBalloonOf poiItem: MTMapPOIItem!) {
    let dict = CompanyList[poiItem.tag]
    let vc = UIStoryboard.init(name: "Cafe", bundle: nil).instantiateViewController(withIdentifier: "cafeDetail") as! CafeDetailVC
    vc.id = dict.id
    self.navigationController?.pushViewController(vc, animated: true)
  }
}
