//
//  ViewController.swift
//  roomEscape_re
//
//  Created by hoonKim on 2021/11/14.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var practiceBtn: UIBarButtonItem!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }

  
  @IBAction func practiceButtonPressed(_ sender: UIBarButtonItem) {
      performSegue(withIdentifier: "practiceButton", sender: nil)
  }
  
}

