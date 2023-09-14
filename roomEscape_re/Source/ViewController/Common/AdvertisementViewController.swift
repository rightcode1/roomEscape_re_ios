//
//  AdvertisementViewController.swift
//  ppuryo
//
//  Created by hoonKim on 2021/05/31.
//

import UIKit
import Kingfisher
import Alamofire
import SwiftyJSON

class AdvertisementViewController: BaseViewController {
  
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
  @IBOutlet var goUrl: UIButton!
  
  var imageURL: String?
  var diff: String = "이벤트"
  var id: Int = 0

  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.navigationBar.isHidden = false
      initDetail()
  }
    func initDetail() {
      self.showHUD()
      let apiurl = "/v1/advertisement/detail"
      
      let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiurl)")!
      let requestURL = url
        .appending("id", value: "\(id)")
      var request = URLRequest(url: requestURL)
      request.httpMethod = HTTPMethod.get.rawValue
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      
      AF.request(request).responseJSON { (response) in
        switch response.result {
        case .success(let value):
          let decoder = JSONDecoder()
          let json = JSON(value)
          let jsonData = try? json.rawData()
          print("\(apiurl) responseJson: \(json)")
          if let data = jsonData, let value = try? decoder.decode(AdvertiseDetailResponse.self, from: data) {
            if value.statusCode == 200 {
                self.dismissHUD()
                self.navigationItem.title = value.data.title
                if value.data.companyId != nil{
                    self.goUrl.isHidden = false
                    KingfisherManager.shared.retrieveImage(with: URL(string: value.data.image ?? "")!) { result in
                      switch result {
                        case .success(let value):
                          let image = value.image.resizeToWidth(newWidth: self.view.frame.width)
                          self.imageView.image = image
                          self.imageViewHeight.constant = image.size.height
                        case .failure:
                          break
                      }
                    }
                    self.goUrl.rx.tapGesture().when(.recognized)
                      .bind(onNext: { [weak self] _ in
                          let vc = UIStoryboard.init(name: "Cafe", bundle: nil).instantiateViewController(withIdentifier: "cafeDetail") as! CafeDetailVC
                          vc.id = value.data.companyId
                          self?.navigationController?.pushViewController(vc, animated: true)
                      })
                      .disposed(by: self.disposeBag)
                }else if value.data.themeId != nil{
                    self.goUrl.isHidden = false
                    KingfisherManager.shared.retrieveImage(with: URL(string: value.data.image ?? "")!) { result in
                      switch result {
                        case .success(let value):
                          let image = value.image.resizeToWidth(newWidth: self.view.frame.width)
                          self.imageView.image = image
                          self.imageViewHeight.constant = image.size.height
                        case .failure:
                          break
                      }
                    }
                    self.goUrl.rx.tapGesture().when(.recognized)
                      .bind(onNext: { [weak self] _ in
                          let vc = UIStoryboard.init(name: "Thema", bundle: nil).instantiateViewController(withIdentifier: "DetailThemaVC") as! DetailThemaVC
                          vc.id = value.data.themeId
                          self?.navigationController?.pushViewController(vc, animated: true)
                      })
                      .disposed(by: self.disposeBag)
                    
                }else if value.data.url != nil{
                    self.goUrl.isHidden = false
                    self.goUrl.rx.tapGesture().when(.recognized)
                      .bind(onNext: { [weak self] _ in
                          if let url = URL(string: value.data.url ?? "") {
                            if UIApplication.shared.canOpenURL(url) {
                              UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                          }
                      })
                      .disposed(by: self.disposeBag)
                    
                }else {
                    self.goUrl.isHidden = true
                    KingfisherManager.shared.retrieveImage(with: URL(string: value.data.image ?? "")!) { result in
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
          }
          break
        case .failure:
          print("error: \(response.error!)")
          break
        }
      }
    }
}
