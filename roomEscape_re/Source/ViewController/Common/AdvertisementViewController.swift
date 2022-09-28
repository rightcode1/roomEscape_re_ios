//
//  AdvertisementViewController.swift
//  ppuryo
//
//  Created by hoonKim on 2021/05/31.
//

import UIKit
import Kingfisher

class AdvertisementViewController: UIViewController {
  
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
  @IBOutlet var goUrl: UIButton!
  
  var imageURL: String?
  var diff: String = "이벤트"
  var url: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.navigationBar.isHidden = false
    initWithAdvertisementImage(imageURL,diff)
  }
  
  func initWithAdvertisementImage(_ imageUrlString: String?,_ diff:String) {
    if imageUrlString != nil && diff == "이벤트"{
      goUrl.isHidden = false
      KingfisherManager.shared.retrieveImage(with: URL(string: imageUrlString ?? "")!) { result in
        switch result {
          case .success(let value):
            let image = value.image.resizeToWidth(newWidth: self.view.frame.width)
            self.imageView.image = image
            self.imageViewHeight.constant = image.size.height
          case .failure:
            break
        }
      }
    }else if imageUrlString != nil {
      goUrl.isHidden = true
      KingfisherManager.shared.retrieveImage(with: URL(string: imageUrlString ?? "")!) { result in
        switch result {
          case .success(let value):
            let image = value.image.resizeToWidth(newWidth: self.view.frame.width)
            self.imageView.image = image
            self.imageViewHeight.constant = image.size.height
          case .failure:
            break
        }
      }
    }
  }
  
  @IBAction func tapUrl(_ sender: Any) {
    if let url = URL(string: url ?? "") {
      if UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
      }
    }
  }
}
