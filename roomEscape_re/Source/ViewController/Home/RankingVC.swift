//
//  RankingVC.swift
//  roomEscape_re
//
//  Created by 이남기 on 2/19/24.
//


import UIKit
import Alamofire
import SwiftyJSON
import RxSwift
import RxCocoa
import SwiftUI

class RankingVC: BaseViewController, WishDelegate, UIScrollViewDelegate {
  @IBOutlet weak var areaCollectionView: UICollectionView!
  @IBOutlet weak var contentTableView: UITableView!
  
  var themeList: [ThemaListData] = []
  
  var page: Int = 1
  var check: Bool = false
  
  var areaList: [AreaList] = [.전국, .서울, .경기, .인천, .충청, .경상, .전라, .강원, .제주]
  
  var selectedArea: AreaList = .전국
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initDelegateDatasource()
    contentTableView.isScrollEnabled = true
    getList()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.navigationBar.isHidden = false
  }
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "aaa", let vc = segue.destination as? DetailThemaVC, let id = sender as? Int {
      vc.id = id
    }
  }
  
  func initDelegateDatasource() {
    areaCollectionView.delegate = self
    areaCollectionView.dataSource = self
    
    contentTableView.delegate = self
    contentTableView.dataSource = self
  }
  func getList(){
    self.showHUD()
    let apiurl = "/v1/theme/list"
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiurl)")!
    let requestURL = url
      .appending("page", value:"\(page)")
      .appending("limit", value: "10")
    // 필터 적용
      .appending("area1", value: selectedArea == .전국 ? nil : selectedArea.rawValue)
      .appending("sort", value: "랭킹순")
    
    var request = URLRequest(url: requestURL)
    request.httpMethod = HTTPMethod.get.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    AF.request(request).responseJSON { (response) in
      switch response.result {
      case .success(let value):
        let decoder = JSONDecoder()
        let json = JSON(value)
        let jsonData = try? json.rawData()
        print("\(apiurl) responseJson: \(requestURL)")
        print("\(apiurl) responseJson: \(json)")
        
        if let data = jsonData, let value = try? decoder.decode(ThemaListResponse.self, from: data) {
          if value.statusCode == 200 {
            self.themeList.append(contentsOf: value.list.rows)
            self.check = true
          }
          self.contentTableView.reloadData()
          self.dismissHUD()
        }
        
        break
      case .failure:
        
        print("error: \(response.error!)")
        self.dismissHUD()
        break
      }
    }
  }
  
  func reloadRows(index: Int) {
    let indexPath = IndexPath(row: index, section: 0)
    contentTableView.reloadRows(at: [indexPath], with: .automatic)
  }
  
  func didWishButtonTapped(_ index: Int) {
    if DataHelperTool.token == nil {
      callYesNoMSGDialog(message: "로그인이 필요한 기능입니다.\n로그인 하시겠습니까?") {
        self.moveToLogin()
      }
    } else {
      let dict = themeList[index]
      
      let isWish = dict.isWish ? false : true
      themeWish(dict.id, isWish) { value in
        if value.statusCode <= 201 {
          self.themeList[index].isWish = isWish
          self.themeList[index].wishCount = (isWish ? self.themeList[index].wishCount + 1 : self.themeList[index].wishCount - 1)
          self.reloadRows(index: index)
          
        }
      }
    }
  }
  
}
extension RankingVC: UIViewControllerTransitioningDelegate {
  func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    PresentationController(presentedViewController: presented, presenting: presenting)
  }
}


extension RankingVC: UICollectionViewDataSource, UICollectionViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.bounds.size.height {
      if(check){
        page += 1
        check = false
        getList()
      }
    }
    
  }
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return areaList.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "areaCollectionCell", for: indexPath) as! AreaCell
    
    let area = areaList[indexPath.row].rawValue
    let isEqual = area == selectedArea.rawValue
    print("\(area) - \(selectedArea.rawValue) : \(isEqual)")
    
    cell.areaLabel.text = area
    cell.areaBottomView.isHidden = !(isEqual)
    
    cell.areaLabel.textColor =  isEqual ? UIColor.black : UIColor.lightGray
    
    return cell
  }
  //MARK: - didSelectItemAt
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let area = areaList[indexPath.row]
    
    selectedArea = area
    areaCollectionView.reloadData()
    
    self.page=1
    self.themeList.removeAll()
    contentTableView.reloadData()
    contentTableView.setContentOffset(CGPoint(x: 0, y:0), animated: true)
    getList()
    
  }
  
}


extension RankingVC: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return themeList.count
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = contentTableView.dequeueReusableCell(withIdentifier: "contentTableViewCell", for: indexPath) as! ContentCell
    print("\(themeList.count) , \(indexPath.row)")
    let dict = themeList[indexPath.row]
    cell.initRankingList(index: indexPath.row,dict)
    cell.delegate = self
    cell.index = indexPath.row
    
    cell.selectionStyle = .none
    
    return cell
    
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    //     = contentTableView.contentSize.height
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let dict = themeList[indexPath.row]
    let vc = UIStoryboard.init(name: "Thema", bundle: nil).instantiateViewController(withIdentifier: "DetailThemaVC") as! DetailThemaVC
    vc.id = dict.id
    self.goViewController(vc: vc)
    
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    return 210
  }
  
}
