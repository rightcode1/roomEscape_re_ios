//
//  AgreeVC.swift
//  scramble
//
//  Created by 이남기 on 2022/05/27.
//

import Foundation
import UIKit
import WebKit

class AgreeVC: BaseViewController,WKUIDelegate, WKNavigationDelegate {
  @IBOutlet weak var webView: WKWebView!
  
  var naviTitle: String?

  override func viewDidLoad() {
    navigationItem.title = naviTitle
    if(naviTitle == "이용약관"){
      let agreement = URL(string: "http://3.37.169.42:31311/conditions.html")!
      self.webView.configuration.preferences.javaScriptEnabled = true  //자바스크립트 활성화
      self.webView.load(URLRequest(url: agreement))
    }else{
        let personal = URL(string: "https://roomescape-backend-image.s3.ap-northeast-2.amazonaws.com/privacy/privacy.html")!
        self.webView.configuration.preferences.javaScriptEnabled = true  //자바스크립트 활성화
        self.webView.load(URLRequest(url: personal))
    }
  }
  
}
