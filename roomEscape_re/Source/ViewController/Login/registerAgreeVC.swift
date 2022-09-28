//
//  registerAgreeVC.swift
//  roomEscape_re
//
//  Created by 이남기 on 2022/06/19.
//

import Foundation

class registerAgreeVC:BaseViewController{
  
  @IBAction func tapAgreeUse(_ sender: Any) {
    let vc = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "AgreeVC") as! AgreeVC
    vc.naviTitle = "이용약관"
    self.navigationController?.pushViewController(vc, animated: true)
  }
  @IBAction func tapPersonal(_ sender: Any) {
    let vc = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "AgreeVC") as! AgreeVC
    vc.naviTitle = "개인정보처리 방침"
    self.navigationController?.pushViewController(vc, animated: true)
  }
}
