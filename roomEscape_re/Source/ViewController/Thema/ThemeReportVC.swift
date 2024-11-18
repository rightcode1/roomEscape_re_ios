//
//  ThemeReportVC.swift
//  roomEscape_re
//
//  Created by 이남기 on 2023/09/27.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

protocol ReviewProtoDelegate {
  func reportReview(_ index: Int)
}


class ThemeReportVC: UIViewController {
  @IBOutlet var ReportTextField: UITextField!
  
  var delegate: ReviewProtoDelegate?
  var index: Int?
  var reviewId: Int?
  
  @IBAction func reprot(_ sender: Any) {
    if ReportTextField.text!.isEmpty{
      return
    }
    showHUD()
      let apiurl = "/v1/report/register"
      let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiurl)")!
      let requestURL = url
      var request = URLRequest(url: requestURL)
      
      let param : reviewReportRequest
      param = reviewReportRequest(themeReviewId: reviewId,content:ReportTextField.text!)
      
      request.httpMethod = HTTPMethod.post.rawValue
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      request.httpBody = try! JSONSerialization.data(withJSONObject: param.dictionary ?? [:], options: .prettyPrinted)
      AF.request(request).responseJSON { (response) in
        switch response.result {
        case .success(let value):
          let decoder = JSONDecoder()
          let json = JSON(value)
          let jsonData = try? json.rawData()
          print("\(apiurl) responseJson: \(requestURL)")
          print("\(apiurl) responseJson: \(json)")
          self.delegate?.reportReview(self.index!)
          
          if let data = jsonData, let value = try? decoder.decode(DefaultResponse.self, from: data) {
            if value.statusCode == 200 {
              self.dismissHUD()
              self.dismiss(animated: true)
            }else{
              self.dismissHUD()
              self.showToast(message: value.message);
        
          }
          
          break
        }
        case .failure(_):
          self.dismissHUD()
          print("error: \(response.error!)")
          break
        }
      }
  }
}
