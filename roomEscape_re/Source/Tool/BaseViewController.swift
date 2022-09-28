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

class BaseViewController: UIViewController, UIGestureRecognizerDelegate {
  
  // MARK: Rx
  
  var disposeBag = DisposeBag()
  
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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //    navigationController?.interactivePopGestureRecognizer?.delegate = self
    navigationController?.interactivePopGestureRecognizer?.delegate = nil
    //    swipeRecognizer()
    //    let notificationCenter = NotificationCenter.default
    //    notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
    //
    //    // EnterForeground -> applicationWillEnterForeground -> applcation(_: open url: options:) -> applicationDidBecomeActive 순서로 진행 됨
    //    notificationCenter.addObserver(self, selector: #selector(backgroundMovedToApp), name: UIApplication.didBecomeActiveNotification, object: nil)
  }
  
  //  @objc func appMovedToBackground() {
  //    print("App moved to background!")
  //  }
  //
  //  @objc func backgroundMovedToApp() {
  //    print("Background moved to app!")
  ////    shareEvents()
  //  }
  
  func shareEvents() {
    //    if shareFeedId != 0 {
    //      let vc = UIStoryboard.init(name: "Sns", bundle: nil).instantiateViewController(withIdentifier: "feedList") as! FeedListViewController
    //      vc.shareId = shareFeedId
    //      navigationController?.pushViewController(vc, animated: true)
    //      shareFeedId = 0
    //    }
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
}


