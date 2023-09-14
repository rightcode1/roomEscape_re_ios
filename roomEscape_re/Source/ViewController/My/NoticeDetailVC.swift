//
//  NoticeDetailVC.swift
//  roomEscape_re
//
//  Created by hoon Kim on 2022/03/16.
//

import UIKit

class NoticeDetailVC: UIViewController {
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var contentLabel: UILabel!
  
  
  var titleString: String?
  var contentString: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    titleLabel.text = titleString
    contentLabel.text = contentString
    
  }
  
  
}
