//
//  EventVC.swift
//  roomEscape_re
//
//  Created by 이남기 on 2022/04/29.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreLocation
import Kingfisher

class EventVC : BaseViewController{
    @IBOutlet weak var table: UITableView!
    var eventList: [AdvertisementData] = []



    override func viewDidLoad() {    navigationController?.navigationBar.isHidden = false
        tabBarController?.tabBar.isHidden = true
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        initEventList()
    }
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    func initEventList(){
        showHUD()
          let apiUrl = "/v1/advertisement/list"
          let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiUrl)")!
          let requestURL = url
            .appending("location", value: "이벤트")
          var request = URLRequest(url: requestURL)
          
          request.httpMethod = HTTPMethod.get.rawValue
          request.setValue("application/json", forHTTPHeaderField: "Content-Type")
          request.addValue("\(DataHelperTool.token ?? "")", forHTTPHeaderField: "Authorization")
          //    request.httpBody = try! JSONSerialization.data(withJSONObject: param.dictionary ?? [:], options: .prettyPrinted)
          
          AF.request(request).responseJSON { (response) in
            switch response.result {
            case .success(let value):
              let decoder = JSONDecoder()
              let json = JSON(value)
              let jsonData = try? json.rawData()
              
              print("\(apiUrl) responseJson: \(json)")
              
              if let data = jsonData, let value = try? decoder.decode(AdvertisementListResponse.self, from: data) {
                if value.statusCode == 200 {
                  self.eventList.removeAll()
                  self.eventList = value.list
                  self.table.reloadData()
                } else {
                  self.callMSGDialog(message: value.message)
                }
                  self.dismissHUD()
              }
              break
            case .failure:
              self.dismissHUD()
              print("\(apiUrl) error: \(response.error!)")
              break
            }
          }
    }

}

extension EventVC: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return eventList.count
  }
    
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//                      if scrollView.contentOffset.y > scrollView.contentSize.height-scrollView.bounds.size.height {
//                          if(check){
//                                  page += 1
//                                  check = false
//                              initCafeList()
//
//                          }
//                      }
//
//    }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.table.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
      let dict = eventList[indexPath.row]
      cell.Thumbnail.kf.setImage(with: URL(string: dict.thumbnail!))
      cell.Title.text = dict.title
    
      cell.date.text = "\(dict.endDate)까지"
    if dict.endDate == nil{
      cell.date.isHidden = true
    }
//    cell.selectionStyle = .none
    
    return cell
    
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        print("indexPath.row : \(indexPath.row)")
        let dict = eventList[indexPath.row]
    
      if dict.image != nil {
          let vc = UIStoryboard.init(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "advertisement") as! AdvertisementViewController
          vc.id = dict.id
          self.navigationController?.pushViewController(vc, animated: true)
        } else {
          if let url = URL(string: dict.url ?? "") {
            if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
          }
        }
    
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    return 270
      
      
  }
  
}
