//
//  AlarmListViewController.swift
//  roomEscape_re
//
//  Created by 이남기 on 4/18/24.
//

import Foundation
import Cosmos

class AlarmListViewController: BaseViewController{
  
  @IBOutlet var themeView: UIView!
  @IBOutlet var historyView: UIView!
  @IBOutlet var mainTableView: UITableView!{
    didSet{
      mainTableView.delegate = self
      mainTableView.dataSource = self
    }
  }
  @IBOutlet var registerView: UIView!
  
  var themeList:[AlarmTheme] = []
  var historyList:[AlarmHistory] = []
  
  
  var selecetMenu: String = "테마"{
    didSet{
      switch selecetMenu{
      case "테마":
        themeView.isHidden = false
        historyView.isHidden = true
        registerView.isHidden = false
        initAlarmTheme()
        break;
      case "내역":
        themeView.isHidden = true
        historyView.isHidden = false
        registerView.isHidden = true
        initAlarmHistory()
        break;
      default:
        break;
      }
    }
  }
  
  @IBAction func themeButton(_ sender: Any) {
    selecetMenu = "테마"
  }
  
  @IBAction func historyButton(_ sender: Any) {
    selecetMenu = "내역"
  }
  @IBAction func registerButton(_ sender: Any) {
    if !(DataHelperTool.isSub ?? false){
      let vc = UIStoryboard.init(name: "Alarm", bundle: nil).instantiateViewController(withIdentifier: "AlarmViewController") as! AlarmViewController
      self.navigationController?.pushViewController(vc, animated: true)
      return
    }
    let vc = UIStoryboard.init(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "CommunityThemeListViewController") as! CommunityThemeListViewController
    vc.isAlarm = true
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.navigationBar.isHidden = false
    initAlarmTheme()
  }
  
  func initAlarmHistory() {
    self.showHUD()
    ApiService.request(router: AlarmApi.alarmHistoryList , success: { (response: ApiResponse<AlarmHistoryListResponse>) in
      guard response.value != nil else {
        return
      }
      self.historyList = response.value?.list ?? []
      self.mainTableView.reloadData()
      self.dismissHUD()
    }) { (error) in
      self.dismissHUD()
    }
  }
  
  func initAlarmTheme() {
    self.showHUD()
    ApiService.request(router: AlarmApi.alarmThemeList , success: { (response: ApiResponse<AlarmThemeListResponse>) in
      guard response.value != nil else {
        return
      }
      self.themeList = response.value?.list ?? []
      self.mainTableView.reloadData()
      self.dismissHUD()
    }) { (error) in
      self.dismissHUD()
    }
  }
  
  
}
extension AlarmListViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if selecetMenu == "테마"{
      return themeList.count
    }else{
      return historyList.count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if selecetMenu == "테마"{
      let cell = mainTableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath)
      let dictTheme = themeList[indexPath.row].theme
      let dict = themeList[indexPath.row]
      
      let themeName = cell.viewWithTag(1) as! UILabel
      let themeDiff = cell.viewWithTag(2) as! UILabel
      let themeCompany = cell.viewWithTag(3) as! UILabel
      let ratingView = cell.viewWithTag(4) as! CosmosView
      let ratingLabel = cell.viewWithTag(5) as! UILabel
      let likeCountLabel = cell.viewWithTag(6) as! UILabel
      let themeImageView = cell.viewWithTag(7) as! UIImageView
      let diffLabel1 = cell.viewWithTag(8) as! UIView
      let diffLabel2 = cell.viewWithTag(9) as! UIView
      
      
      themeImageView.kf.setImage(with: URL(string: dictTheme.thumbnail ?? ""))
      themeName.text = dictTheme.title
      themeDiff.text = dictTheme.category
      diffLabel1.isHidden = !dict.diff.contains("양도/교환")
      diffLabel2.isHidden = !dict.diff.contains("일행구하기")
      themeCompany.text = dictTheme.companyName
      ratingView.rating = dictTheme.grade
      ratingLabel.text = "\(dictTheme.grade)"
      likeCountLabel.text = "\(dictTheme.wishCount)"
      
      cell.selectionStyle = .none
      return cell
    }else{
      let cell = mainTableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath)
      let dict = historyList[indexPath.row]
      
      let imageView = cell.viewWithTag(1) as! UIImageView
      let diff = cell.viewWithTag(2) as! UILabel
      let name = cell.viewWithTag(3) as! UILabel
      let createdAt = cell.viewWithTag(4) as! UILabel
      
      
      imageView.kf.setImage(with: URL(string: dict.theme.thumbnail ?? ""))
      diff.text = dict.diff
      name.text = dict.content
      createdAt.text = dict.createdAt
      
      cell.selectionStyle = .none
      return cell
    }
  }
  
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if selecetMenu == "테마"{
      let dict = themeList[indexPath.row]
      let vc = UIStoryboard.init(name: "Thema", bundle: nil).instantiateViewController(withIdentifier: "DetailThemaVC") as! DetailThemaVC
      vc.id = dict.theme.id
      self.goViewController(vc: vc)
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 110
  }
  
}
