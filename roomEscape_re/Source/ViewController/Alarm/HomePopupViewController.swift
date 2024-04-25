//
//  HomePopupViewController.swift
//  roomEscape_re
//
//  Created by 이남기 on 4/18/24.
//

import Foundation


import UIKit

protocol HomePopupDelegate {
  func tapPopup()
}

class HomePopupViewController: BaseViewController {
  @IBOutlet var imageVIew: UIImageView!
  let formatter = DateFormatter()
  var delegate: HomePopupDelegate?
  var id: Int?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initrx()
  }
  
  func initrx(){
    imageVIew.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        self?.backPress()
        self?.delegate?.tapPopup()
      })
      .disposed(by: disposeBag)
  }
  
  func figureOutHeight(urlString: URL, height: NSLayoutConstraint) {
    let url = urlString
    if let data = try? Data(contentsOf: url) {
      if let img = UIImage(data: data) {
        print("img: \(img)")
        let diff = ((self.view.frame.width) / img.size.width)
        print("diff: \(diff)")
        print("viewWidth: \(self.view.frame.width)")
        let h = img.size.height * diff
        height.constant = h
      }
    }
  }
  @IBAction func back(_ sender: Any) {
    self.backPress()
  }
  
  @IBAction func stopToday(_ sender: UIButton) {
    formatter.dateFormat = "MMdd"
    var today = formatter.string(for: Date()) ?? ""
    DataHelper.set(today, forKey: .popupDate)
    self.backPress()
  }
  
}
