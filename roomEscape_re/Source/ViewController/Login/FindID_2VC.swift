//
//  FindID_2ViewController.swift
//  ppuryoManager_ios
//
//  Created by hoonKim on 2021/09/29.
//

import UIKit


class FindID_2VC: UIViewController {
  
  @IBOutlet weak var idLabel: UILabel!
  @IBOutlet weak var shadowView: UIView!
  
  var id: String!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    shadowView.layer.applySketchShadow(color: .black, alpha: 0.16, x: 0, y: 1.0, blur: 3, spread: 0)
    shadowView.layer.cornerRadius = 3
    
    idLabel.text = id 
  }
  
  @IBAction func tapLogin(_ sender: UIButton) {
    self.navigationController?.popToRootViewController(animated: true)
  }
}
