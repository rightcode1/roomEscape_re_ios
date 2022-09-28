//
//  UpdateViewController.swift
//  industrialAccidentAI
//
//  Created by hoonKim on 2021/07/28.
//

import UIKit

class UpdateViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
  
  @IBAction func tapUpdate(_ sender: UIButton) {
    if let url = URL(string: "itms-apps://itunes.apple.com/app/1441281712"), UIApplication.shared.canOpenURL(url) { if #available(iOS 10.0, *) { UIApplication.shared.open(url, options: [:], completionHandler: nil) } else { UIApplication.shared.openURL(url) } }
  }

}
