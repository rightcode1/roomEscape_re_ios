//
//  BaseViewController.swift
//  cheorwonHotPlace
//
//  Created by hoon Kim on 28/01/2020.
//  Copyright © 2020 hoon Kim. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture
import Alamofire
import SwiftyJSON
import UserNotifications
import GoogleMobileAds

class BaseViewController: UIViewController, UIGestureRecognizerDelegate {
  
  // MARK: Rx
  
  var disposeBag = DisposeBag()
  private var interstitial: GADInterstitialAd?
  private var vc : UIViewController?
  
  @IBInspectable var localizedText: String = "" {
    didSet {
      if localizedText.count > 0 {
#if TARGET_INTERFACE_BUILDER
        var bundle = NSBundle(forClass: type(of: self))
        self.title = bundle.localizedStringForKey(self.localizedText, value:"", table: nil)
#else
        self.title = NSLocalizedString(self.localizedText, comment:"");
#endif
      }
    }
  }
  func isValidEmail(testStr:String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: testStr)
  }
  
  func userInfo(result: @escaping (UserInfoResponse) -> Void) {
    ApiService.request(router: UserApi.userInfo, success: { (response: ApiResponse<UserInfoResponse>) in
      guard let value = response.value else {
        return
      }
      DataHelper.set(value.data?.id, forKey: .userAppId)
      DataHelper.set(value.data?.name, forKey: .userNickname)
      result(value)
    }) { (error) in
    }
  }
  func updateSubToken(diff: String,token: String) {
    print("updateSubToken : \(token)")
    let apiurl = "/v1/user/update"
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiurl)")!
    let requestURL = url
    
    var request = URLRequest(url: requestURL)
    var param : UserUpdateRequest
    if diff == "ios"{
      param = UserUpdateRequest(iosPurchaseToken: token)
    }else{
      param = UserUpdateRequest(androidPurchaseToken: token)
    }
    
    request.httpMethod = HTTPMethod.put.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("\(DataHelperTool.token ?? "")", forHTTPHeaderField: "Authorization")
    
    request.httpBody = try! JSONSerialization.data(withJSONObject: param.dictionary ?? [:], options: .prettyPrinted)
    
    AF.request(request).responseJSON { [self] (response) in
      switch response.result {
      case .success(let value):
        let decoder = JSONDecoder()
        let json = JSON(value)
        let jsonData = try? json.rawData()
        
        print("\(apiurl) responseJson: \(json)")
        
        if let data = jsonData, let value = try? decoder.decode(DefaultIDResponse.self, from: data) {
          if value.statusCode == 200 {
            if token != ""{
              DataHelper.set(true, forKey: .isSub)
            }
          }
        }
        break
      case .failure:
        print("\(apiurl) error: \(response.error!)")
        break
      }
    }
  }
  
  func getReceiptData() -> String? {
    let receiptFileURL = Bundle.main.appStoreReceiptURL
    let receiptData = NSData(contentsOf: receiptFileURL!)
    let recieptString = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    return recieptString
  }
  
  
  func subCheck(iosReceipt : String?, result: @escaping (Bool) -> Void){
    if iosReceipt == nil || iosReceipt == ""{
      DataHelper.set(false, forKey: .isSub)
      updateSubToken(diff: "ios", token: "")
      print("ios 영수증이 없습니다.")
      result(false)
    }
    
    let param = IosSubRequest (
      receiptData: iosReceipt!,
      isTest: false
    )
    
    var request = URLRequest(url: URL(string: "\(ApiEnvironment.baseUrl)/iosSub")!)
    request.httpMethod = HTTPMethod.post.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("\(DataHelperTool.token ?? "")", forHTTPHeaderField: "Authorization")
    request.httpBody = try! JSONSerialization.data(withJSONObject: param.dictionary ?? [:], options: .prettyPrinted)
    
    AF.request(request).responseJSON { [self] (response) in
      print(response)
      switch response.result {
      case .success(let value):
        let decoder = JSONDecoder()
        let json = JSON(value)
        let jsonData = try? json.rawData()
        if let data = jsonData, let value = try? decoder.decode(IosSubResponse.self, from: data) {
          if value.latest_receipt_info.isEmpty{
            print("ios 영수증정보가 비어있습니다.")
            updateSubToken(diff: "ios", token: "")
            DataHelper.set(false, forKey: .isSub)
            result(false)
            return
          }
          let formatter2 = DateFormatter()
          formatter2.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
          let date = value.latest_receipt_info.first!.expires_date
          print(formatter2.date(from: date)!)
          print(Date())
          print(formatter2.date(from: date)! > Date())
          if formatter2.date(from: date)! > Date(){
            updateSubToken(diff: "ios", token: iosReceipt!)
            DataHelper.set(true, forKey: .isSub)
            result(true)
          }else{
            DataHelper.set(false, forKey: .isSub)
            updateSubToken(diff: "ios", token: "")
            result(false)
          }
        }else{
          showToast(message: "영수증 검증에러")
          DataHelper.set(false, forKey: .isSub)
          result(false)
          print("ios 영수증 검사 에러!!!")
        }
        break
      case .failure:
        DataHelper.set(false, forKey: .isSub)
        result(false)
        print("ios 영수증 검사 에러!!!")
        break
      }
    }
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.interactivePopGestureRecognizer?.delegate = nil
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func backTwo() {
    let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
    self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
  }
  
  
  func cafeWish(_ companyId: Int, _ isWish: Bool, result: @escaping (DefaultResponse) -> Void) {
    let apiurl = "/v1/companyWish/\(isWish ? "register" : "remove")"
    
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiurl)")!
    let requestURL = url
      .appending("companyId", value: isWish ? nil : "\(companyId)")
    var request = URLRequest(url: requestURL)
    request.httpMethod = isWish ? HTTPMethod.post.rawValue : HTTPMethod.delete.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("\(DataHelperTool.token ?? "")", forHTTPHeaderField: "Authorization")
    
    request.httpBody = try! JSONSerialization.data(withJSONObject: isWish ? ["companyId": companyId] : [], options: .prettyPrinted)
    
    AF.request(request).responseJSON { (response) in
      switch response.result {
      case .success(let value):
        let decoder = JSONDecoder()
        let json = JSON(value)
        let jsonData = try? json.rawData()
        print("\(apiurl) responseJson: \(json)")
        if let data = jsonData, let value = try? decoder.decode(DefaultResponse.self, from: data) {
          result(value)
        }
        break
      case .failure:
        print("error: \(response.error!)")
        break
      }
    }
  }
  
  func themeWish(_ themeId: Int, _ isWish: Bool, result: @escaping (DefaultResponse) -> Void) {
    let apiurl = "/v1/themeWish/\(isWish ? "register" : "remove")"
    
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiurl)")!
    let requestURL = url
      .appending("themeId", value: isWish ? nil : "\(themeId)")
    var request = URLRequest(url: requestURL)
    request.httpMethod = isWish ? HTTPMethod.post.rawValue : HTTPMethod.delete.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("\(DataHelperTool.token ?? "")", forHTTPHeaderField: "Authorization")
    
    request.httpBody = try! JSONSerialization.data(withJSONObject: isWish ? ["themeId": themeId] : [], options: .prettyPrinted)
    
    AF.request(request).responseJSON { (response) in
      switch response.result {
      case .success(let value):
        let decoder = JSONDecoder()
        let json = JSON(value)
        let jsonData = try? json.rawData()
        print("\(apiurl) responseJson: \(json)")
        if let data = jsonData, let value = try? decoder.decode(DefaultResponse.self, from: data) {
          result(value)
        }
        break
      case .failure:
        print("error: \(response.error!)")
        break
      }
    }
  }
  func swipeRecognizer() {
    let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
    swipeRight.direction = UISwipeGestureRecognizer.Direction.right
    self.view.addGestureRecognizer(swipeRight)
    
  }
  
  @objc func respondToSwipeGesture(_ gesture: UIGestureRecognizer){
    if let swipeGesture = gesture as? UISwipeGestureRecognizer {
      switch swipeGesture.direction{
      case UISwipeGestureRecognizer.Direction.right:
        // 스와이프 시, 원하는 기능 구현.
        self.dismiss(animated: true, completion: nil)
      default: break
      }
    }
  }
  func goViewController(vc: UIViewController){
    self.vc = vc
    if (DataHelperTool.isSub ?? false){
      self.navigationController?.pushViewController(vc, animated: true)
      return
    }
    if (DataHelperTool.adCount ?? 0 % 10 == 0 || DataHelperTool.adCount == 1) && (vc is CafeDetailVC || vc is DetailThemaVC){
      showAD()
    }else{
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }
  
  func showAD(){
    if interstitial != nil{
      self.interstitial?.present(fromRootViewController: self)
    }else{
      isInterstitial(true)
    }
  }
  func isInterstitial(_ isLogding: Bool){
    if isLogding{
      showHUD()
    }
    let request = GADRequest()
    GADInterstitialAd.load(withAdUnitID: "ca-app-pub-6757436006436446/1087298264",
                           request: request,
                           completionHandler: { [self] ad, error in
      if let error = error {
        dismissHUD()
        interstitial = nil
        print("Failed to load interstitial ad with error: \(error.localizedDescription)")
        self.navigationController?.pushViewController(vc!, animated: true)
        return
      }
      interstitial = ad
      interstitial?.fullScreenContentDelegate = self
      dismissHUD()
      if isLogding{
        self.interstitial?.present(fromRootViewController: self)
      }
    })
  }
}
extension BaseViewController: GADFullScreenContentDelegate {
  /// Tells the delegate that the ad failed to present full screen content.
  func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
    interstitial = nil
    self.navigationController?.pushViewController(vc!, animated: true)
    print("Ad did fail to present full screen content.")
  }
  
  /// Tells the delegate that the ad will present full screen content.
  func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("Ad will present full screen content.")
  }
  
  /// Tells the delegate that the ad dismissed full screen content.
  func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("Ad did dismiss full screen content.")
    self.navigationController?.pushViewController(vc!, animated: true)
    interstitial = nil
  }
}


