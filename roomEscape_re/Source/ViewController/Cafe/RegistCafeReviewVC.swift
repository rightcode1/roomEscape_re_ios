//
//  RegistCafeReviewVC.swift
//  roomEscape_re
//
//  Created by hoon Kim on 2022/02/04.
//

import UIKit
import Cosmos
import Alamofire
import SwiftyJSON

class RegistCafeReviewVC: UIViewController {
  
  @IBOutlet weak var ratingView: CosmosView!
  
  @IBOutlet weak var contentTextView: UITextView!
  
  var reviewData: CompanyReview?
  
  var companyId: Int!
  
  var rating = 0.0 {
    didSet {
      ratingView.rating = rating
    }
  }
  
  var contentTextViewPlaceHolder: String = "후기 입력"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    contentTextView.delegate = self
    ratingView.rating = 5
    ratingView.settings.minTouchRating = 1
    rating = 5
    ratingView.settings.fillMode = .full
    ratingView.didFinishTouchingCosmos = { rating in
      self.rating = rating
    }
    ratingView.didTouchCosmos = { rating in
      self.rating = rating
    }
   
    initWithReviewData()
  }
  
  func initWithReviewData() {
    if reviewData != nil {
      ratingView.rating = reviewData?.grade ?? 0.0
      contentTextView.text = reviewData?.contents
    }
  }
  
  func textViewSetupView() {
    if contentTextView.text == contentTextViewPlaceHolder {
      contentTextView.text = ""
      contentTextView.textColor = .black
    } else if contentTextView.text.isEmpty {
      contentTextView.text = contentTextViewPlaceHolder
      contentTextView.textColor = UIColor.lightGray
    }
  }
  
  func registAndUpdate() {
    self.showHUD()
    let apiUrl = "/v1/companyReview/\(reviewData == nil ? "register" : "update")"
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiUrl)")!
    let requestURL = url
      .appending("id", value: reviewData == nil ? nil : "\(reviewData?.id ?? 0)")
    var request = URLRequest(url: requestURL)
    
    request.httpMethod = reviewData == nil ? HTTPMethod.post.rawValue : HTTPMethod.put.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("\(DataHelperTool.token ?? "")", forHTTPHeaderField: "Authorization")
    
    request.httpBody = try! JSONSerialization.data(withJSONObject: ["companyId": companyId ?? 0,
                                                                    "grade": rating,
                                                                    "contents": contentTextView.text ?? ""], options: .prettyPrinted)
    
    AF.request(request).responseJSON { [self] (response) in
      switch response.result {
      case .success(let value):
        let decoder = JSONDecoder()
        let json = JSON(value)
        let jsonData = try? json.rawData()
        
        print("\(apiUrl) responseJson: \(json)")
        
        if let data = jsonData, let value = try? decoder.decode(DefaultResponse.self, from: data) {
          if value.statusCode == 200 {
            self.callOkActionMSGDialog(message: "등록되었습니다.") {
              self.backPress()
            }
          } else {
            self.callMSGDialog(message: value.message)
            self.dismissHUD()
          }
        }
        break
      case .failure:
        print("\(apiUrl) error: \(response.error!)")
        self.dismissHUD()
        break
      }
    }
  }
  
  @IBAction func tapRegist(_ sender: UIButton) {
    
    if contentTextView.text == contentTextViewPlaceHolder || contentTextView.text.isEmpty {
      callMSGDialog(message: "후기를 입력해 주세요.")
      return
    }
    
    registAndUpdate()
  }
  
}
extension RegistCafeReviewVC: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    textViewSetupView()
    
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    if self.contentTextView.text == "" {
      textViewSetupView()
    }
  
  }
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if text == "\n" {
      //                self.inquiryContentTextView.resignFirstResponder()
    }
    return true
  }
}
