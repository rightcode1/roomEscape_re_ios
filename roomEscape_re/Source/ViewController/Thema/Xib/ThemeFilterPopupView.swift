//
//  ThemeFilterPopupView.swift
//  roomEscape_re
//
//  Created by hoon Kim on 2022/03/03.
//

import UIKit

extension UIView {
  func roundCorners(_ corners: UIRectCorner , radius: CGFloat) {
    let path = UIBezierPath(roundedRect: self.bounds,
                            byRoundingCorners: corners,
                            cornerRadii: CGSize(width: radius, height: radius))
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    self.layer.mask = mask
  }
}

protocol ThemeFilterDelegate {
  func setFilter(_ filter: ThemeListRequest)
}


class ThemeFilterPopupView: UIViewController {
  @IBOutlet weak var backView: UIView!
  
  @IBOutlet var sortCollectionView: UICollectionView!
  @IBOutlet var typeCollectionView: UICollectionView!
  @IBOutlet var rateCollectionView: UICollectionView!
  @IBOutlet var levelCollectionView: UICollectionView!
  @IBOutlet var personCollectionView: UICollectionView!
  @IBOutlet var toolCollectionView: UICollectionView!
  @IBOutlet var activityCollectionView: UICollectionView!
  @IBOutlet var myReviewCollectionView: UICollectionView!
  
  var delegate: ThemeFilterDelegate?
  
  var hasSetPointOrigin = false
  var pointOrigin: CGPoint?
  
  var themeFilter = ThemeListRequest()
  
  var themeSortList: [ThemeSort] = [.전방추천순, .거리순]
  var themeTypeList: [ThemeType] = [.전체, .신규테마, .이색컨텐츠, .혼방가능]
  var themeRateList: [ThemeRate] = [.전체, .점대1, .점대2, .점대3, .점대4]
  var themeLevelList: [ThemeLevel] = [.전체, .one, .two, .three, .four, .five]
  var themePersonList: [ThemePersonCount] = [.전체, .two, .three, .four, .five]
  var themeToolList: [ThemeTool] = [.전체, .높음, .보통, .낮음]
  var themeActivityList: [ThemeTool] = [.전체, .높음, .보통, .낮음]
  var isMyReview: Bool = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
    view.addGestureRecognizer(panGesture)
    
    backView.roundCorners([.topLeft, .topRight], radius: 25)
    themeFilter = DataHelperTool.themeListFilter ?? ThemeListRequest()
    allCollectionViewReloadData()
  }
  
  override func viewDidLayoutSubviews() {
    if !hasSetPointOrigin {
      hasSetPointOrigin = true
      pointOrigin = self.view.frame.origin
    }
  }
  
  @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
    let translation = sender.translation(in: view)
    
    // Not allowing the user to drag the view upward
    guard translation.y >= 0 else { return }
    
    // setting x as 0 because we don't want users to move the frame side ways!! Only want straight up or down
    view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)
    
    if sender.state == .ended {
      let dragVelocity = sender.velocity(in: view)
      if dragVelocity.y >= 1300 {
        self.backPress()
      } else {
        // Set back to original position of the view controller
        UIView.animate(withDuration: 0.3) {
          self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 172)
        }
      }
    }
  }
  
  func allCollectionViewReloadData() {
    sortCollectionView.reloadData()
    typeCollectionView.reloadData()
    rateCollectionView.reloadData()
    levelCollectionView.reloadData()
    personCollectionView.reloadData()
    toolCollectionView.reloadData()
    activityCollectionView.reloadData()
    myReviewCollectionView.reloadData()
  }
  
  func textWidth(text: String, font: UIFont?) -> CGFloat {
    let attributes = font != nil ? [NSAttributedString.Key.font: font] : [:]
    return text.size(withAttributes: attributes as [NSAttributedString.Key : Any]).width
  }
  
  @IBAction func tapRefresh(_ sender: UIButton) {
    themeFilter = ThemeListRequest()
    allCollectionViewReloadData()
  }
  
  @IBAction func tapSaveFilter(_ sender: UIButton) {
    DataHelper<ThemeListRequest>.setThemeListFilter(self.themeFilter)
    delegate?.setFilter(self.themeFilter)
    backPress()
  }
  
}


extension ThemeFilterPopupView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView == sortCollectionView {
      return themeSortList.count
    } else if collectionView == typeCollectionView {
      return themeTypeList.count
    } else if collectionView == rateCollectionView {
      return themeRateList.count
    } else if collectionView == levelCollectionView {
      return themeLevelList.count
    } else if collectionView == personCollectionView {
      return themePersonList.count
    } else if collectionView == toolCollectionView {
      return themeToolList.count
    } else if collectionView == activityCollectionView {
      return themeActivityList.count
    } else {
      return 2
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if collectionView == sortCollectionView {
      let cell = sortCollectionView.dequeueReusableCell(withReuseIdentifier: "cell1", for: indexPath)
      print("sort----------------")
      guard let titleLabel = cell.viewWithTag(2) as? UILabel else {
        return cell
      }
      
      let diff = themeSortList[indexPath.row].rawValue
      var isSame = themeSortList[indexPath.row] == themeFilter.sort
      
      titleLabel.text = diff
      
      titleLabel.layer.cornerRadius = 5
      titleLabel.layer.masksToBounds = true
      titleLabel.textColor = isSame ? colorFromRGB(0xffa200) : colorFromRGB(0xaaaaaa)
      titleLabel.backgroundColor = isSame ? colorFromRGB(0xffefbc) : colorFromRGB(0xffffff)
      titleLabel.layer.borderWidth = isSame ? 0 : 1
      titleLabel.layer.borderColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1.0).cgColor
      
      return cell
    } else if collectionView == typeCollectionView {
      let cell = typeCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
      
      guard let titleLabel = cell.viewWithTag(2) as? UILabel else {
        return cell
      }
      
      let diff = themeTypeList[indexPath.row].rawValue
      var isSame = false
      for count in 0..<(themeFilter.type.count){
        isSame = themeTypeList[indexPath.row] == themeFilter.type[count]
        if isSame{
          break
        }
      }
      print("\(indexPath.row) : \(isSame)")
      
      titleLabel.text = diff
      
      titleLabel.layer.cornerRadius = 5
      titleLabel.layer.masksToBounds = true
      titleLabel.textColor = isSame ? colorFromRGB(0xffa200) : colorFromRGB(0xaaaaaa)
      titleLabel.backgroundColor = isSame ? colorFromRGB(0xffefbc) : colorFromRGB(0xffffff)
      titleLabel.layer.borderWidth = isSame ? 0 : 1
      titleLabel.layer.borderColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1.0).cgColor
      
      return cell
    } else if collectionView == rateCollectionView {
      let cell = rateCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
      
      guard let titleLabel = cell.viewWithTag(2) as? UILabel else {
        return cell
      }
      
      let diff = themeRateList[indexPath.row].rawValue
      var isSame = false
      for count in 0..<(themeFilter.rate.count){
        isSame = themeRateList[indexPath.row] == themeFilter.rate[count]
        if isSame{
          break
        }
      }
      
      titleLabel.text = diff
      
      titleLabel.layer.cornerRadius = 5
      titleLabel.layer.masksToBounds = true
      titleLabel.textColor = isSame ? colorFromRGB(0xffa200) : colorFromRGB(0xaaaaaa)
      titleLabel.backgroundColor = isSame ? colorFromRGB(0xffefbc) : colorFromRGB(0xffffff)
      titleLabel.layer.borderWidth = isSame ? 0 : 1
      titleLabel.layer.borderColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1.0).cgColor
      
      return cell
    } else if collectionView == levelCollectionView {
      let cell = levelCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
      
      guard let titleLabel = cell.viewWithTag(2) as? UILabel,
            let levelStackView = cell.viewWithTag(3) as? UIStackView else {
              return cell
            }
      
      let dict = themeLevelList[indexPath.row]
      
      let diff = dict.rawValue
      var isSame = false
      for count in 0..<(themeFilter.level.count){
        isSame = themeLevelList[indexPath.row] == themeFilter.level[count]
        if isSame{
          break
        }
      }
      levelStackView.isHidden = dict == .전체
      
      titleLabel.text = dict == .전체 ? diff : ""
      
      titleLabel.layer.cornerRadius = 5
      titleLabel.layer.masksToBounds = true
      titleLabel.textColor = isSame ? colorFromRGB(0xffa200) : colorFromRGB(0xaaaaaa)
      titleLabel.backgroundColor = isSame ? colorFromRGB(0xffefbc) : colorFromRGB(0xffffff)
      titleLabel.layer.borderWidth = isSame ? 0 : 1
      titleLabel.layer.borderColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1.0).cgColor
      
      let level = dict.level
      
      let hiddenCount = 5 - level
      
      for i in 0..<level {
        levelStackView.arrangedSubviews[i].isHidden = false
      }
      
      for i in 0..<hiddenCount {
        levelStackView.arrangedSubviews[4-i].isHidden = true
      }
      
      return cell
    } else if collectionView == personCollectionView {
      let cell = personCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
      
      guard let titleLabel = cell.viewWithTag(2) as? UILabel else {
        return cell
      }
      
      let diff = themePersonList[indexPath.row].rawValue
      var isSame = false
      for count in 0..<(themeFilter.person.count){
        isSame = themePersonList[indexPath.row] == themeFilter.person[count]
        if isSame{
          break
        }
      }
      
      titleLabel.text = diff
      
      titleLabel.layer.cornerRadius = 5
      titleLabel.layer.masksToBounds = true
      titleLabel.textColor = isSame ? colorFromRGB(0xffa200) : colorFromRGB(0xaaaaaa)
      titleLabel.backgroundColor = isSame ? colorFromRGB(0xffefbc) : colorFromRGB(0xffffff)
      titleLabel.layer.borderWidth = isSame ? 0 : 1
      titleLabel.layer.borderColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1.0).cgColor
      
      return cell
    } else if collectionView == toolCollectionView {
      let cell = toolCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
      
      guard let titleLabel = cell.viewWithTag(2) as? UILabel else {
        return cell
      }
      
      let diff = themeToolList[indexPath.row].rawValue
      var isSame = false
      for count in 0..<(themeFilter.tool.count){
        isSame = themeToolList[indexPath.row] == themeFilter.tool[count]
        if isSame{
          break
        }
      }
      
      titleLabel.text = diff
      
      titleLabel.layer.cornerRadius = 5
      titleLabel.layer.masksToBounds = true
      titleLabel.textColor = isSame ? colorFromRGB(0xffa200) : colorFromRGB(0xaaaaaa)
      titleLabel.backgroundColor = isSame ? colorFromRGB(0xffefbc) : colorFromRGB(0xffffff)
      titleLabel.layer.borderWidth = isSame ? 0 : 1
      titleLabel.layer.borderColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1.0).cgColor
      
      return cell
    } else if collectionView == activityCollectionView {
      let cell = activityCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
      
      guard let titleLabel = cell.viewWithTag(2) as? UILabel else {
        return cell
      }
      
      let diff = themeActivityList[indexPath.row].rawValue
      var isSame = false
      for count in 0..<(themeFilter.activity.count){
        isSame = themeActivityList[indexPath.row] == themeFilter.activity[count]
        if isSame{
          break
        }
      }
      
      titleLabel.text = diff
      
      titleLabel.layer.cornerRadius = 5
      titleLabel.layer.masksToBounds = true
      titleLabel.textColor = isSame ? colorFromRGB(0xffa200) : colorFromRGB(0xaaaaaa)
      titleLabel.backgroundColor = isSame ? colorFromRGB(0xffefbc) : colorFromRGB(0xffffff)
      titleLabel.layer.borderWidth = isSame ? 0 : 1
      titleLabel.layer.borderColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1.0).cgColor
      
      return cell
    } else {
      let cell = myReviewCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
      
      guard let titleLabel = cell.viewWithTag(2) as? UILabel else {
        return cell
      }
      
      let diff = indexPath.row == 0 ? "ON" : "OFF"
      let isSame = indexPath.row == (themeFilter.isMyReview ?? false ? 0 : 1)
      
      titleLabel.text = diff
      
      titleLabel.layer.cornerRadius = 5
      titleLabel.layer.masksToBounds = true
      titleLabel.textColor = isSame ? colorFromRGB(0xffa200) : colorFromRGB(0xaaaaaa)
      titleLabel.backgroundColor = isSame ? colorFromRGB(0xffefbc) : colorFromRGB(0xffffff)
      titleLabel.layer.borderWidth = isSame ? 0 : 1
      titleLabel.layer.borderColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1.0).cgColor
      
      return cell
    }
    
  }
  //MARK: - didSelectItemAt
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if collectionView == sortCollectionView {
      themeFilter.sort = themeSortList[indexPath.row]
      print(themeFilter.sort)
    } else if collectionView == typeCollectionView {
      if themeFilter.type.count == 1 && themeFilter.type[0] == .전체{
        themeFilter.type[0] = themeTypeList[indexPath.row]
      }else if themeTypeList[indexPath.row] == .전체{
        themeFilter.type.removeAll()
        themeFilter.type = [.전체]
      }else{
        var isSame = false
        for count in 0..<(themeFilter.type.count){
          isSame = themeTypeList[indexPath.row] == themeFilter.type[count]
          if isSame{
            themeFilter.type.remove(at: count)
            break
          }
        }
        if !isSame{
          themeFilter.type.append(themeTypeList[indexPath.row])
        }
      }
      print(themeFilter.type)
      typeCollectionView.reloadData()
    } else if collectionView == rateCollectionView {
      
      if themeFilter.rate.count == 1 && themeFilter.rate[0] == .전체{
        themeFilter.rate[0] = themeRateList[indexPath.row]
      }else if themeRateList[indexPath.row] == .전체{
        themeFilter.rate.removeAll()
        themeFilter.rate = [.전체]
      }else{
        var isSame = false
        for count in 0..<(themeFilter.rate.count){
          isSame = themeRateList[indexPath.row] == themeFilter.rate[count]
          if isSame{
            themeFilter.rate.remove(at: count)
            break
          }
        }
        if !isSame{
          themeFilter.rate.append(themeRateList[indexPath.row])
        }
      }
      print(themeFilter.rate)
      rateCollectionView.reloadData()
      
    } else if collectionView == levelCollectionView {
      
      
      if themeFilter.level.count == 1 && themeFilter.level[0] == .전체{
        themeFilter.level[0] = themeLevelList[indexPath.row]
      }else if themeLevelList[indexPath.row] == .전체{
        themeFilter.level.removeAll()
        themeFilter.level = [.전체]
      }else{
        var isSame = false
        for count in 0..<(themeFilter.level.count){
          isSame = themeLevelList[indexPath.row] == themeFilter.level[count]
          if isSame{
            themeFilter.level.remove(at: count)
            break
          }
        }
        if !isSame{
          themeFilter.level.append(themeLevelList[indexPath.row])
        }
      }
      print(themeFilter.level)
      levelCollectionView.reloadData()
      
      
    } else if collectionView == personCollectionView {
      if themeFilter.person.count == 1 && themeFilter.person[0] == .전체{
        themeFilter.person[0] = themePersonList[indexPath.row]
      }else if themePersonList[indexPath.row] == .전체{
        themeFilter.person.removeAll()
        themeFilter.person = [.전체]
      }else{
        var isSame = false
        for count in 0..<(themeFilter.person.count){
          isSame = themePersonList[indexPath.row] == themeFilter.person[count]
          if isSame{
            themeFilter.person.remove(at: count)
            break
          }
        }
        if !isSame{
          themeFilter.person.append(themePersonList[indexPath.row])
        }
      }
      print(themeFilter.person)
      personCollectionView.reloadData()
      
      
    } else if collectionView == toolCollectionView {
      
      if themeFilter.tool.count == 1 && themeFilter.tool[0] == .전체{
        themeFilter.tool[0] = themeToolList[indexPath.row]
      }else if themeToolList[indexPath.row] == .전체{
        themeFilter.tool.removeAll()
        themeFilter.tool = [.전체]
      }else{
        var isSame = false
        for count in 0..<(themeFilter.tool.count){
          isSame = themeToolList[indexPath.row] == themeFilter.tool[count]
          if isSame{
            themeFilter.tool.remove(at: count)
            break
          }
        }
        if !isSame{
          themeFilter.tool.append(themeToolList[indexPath.row])
        }
      }
      print(themeFilter.tool)
      toolCollectionView.reloadData()
    } else if collectionView == activityCollectionView {
      
      
      if themeFilter.activity.count == 1 && themeFilter.activity[0] == .전체{
        themeFilter.activity[0] = themeActivityList[indexPath.row]
      }else if themeActivityList[indexPath.row] == .전체{
        themeFilter.activity.removeAll()
        themeFilter.activity = [.전체]
      }else{
        var isSame = false
        for count in 0..<(themeFilter.activity.count){
          isSame = themeActivityList[indexPath.row] == themeFilter.activity[count]
          if isSame{
            themeFilter.activity.remove(at: count)
            break
          }
        }
        if !isSame{
          themeFilter.activity.append(themeActivityList[indexPath.row])
        }
      }
      print(themeFilter.activity)
      activityCollectionView.reloadData()
    } else {
      themeFilter.isMyReview = indexPath.row == 0
      myReviewCollectionView.reloadData()
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    10
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    10
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if collectionView == sortCollectionView {
      let text = themeSortList[indexPath.row].rawValue
      let width = textWidth(text: text, font: UIFont.systemFont(ofSize: 12, weight: .medium))
      return CGSize(width: width + 24, height: 25)
    } else if collectionView == typeCollectionView {
      let text = themeTypeList[indexPath.row].rawValue
      let width = textWidth(text: text, font: UIFont.systemFont(ofSize: 12, weight: .medium))
      return CGSize(width: width + 24, height: 25)
    } else if collectionView == rateCollectionView {
      let text = themeRateList[indexPath.row].rawValue
      let width = textWidth(text: text, font: UIFont.systemFont(ofSize: 12, weight: .medium))
      return CGSize(width: width + 24, height: 25)
    } else if collectionView == levelCollectionView {
      //     let text = themeLevelList[indexPath.row].rawValue
      //     let width = textWidth(text: text, font: UIFont.systemFont(ofSize: 12, weight: .medium))
      var width: CGFloat = 50
      
      if indexPath.row == 2 || indexPath.row == 3 {
        width += 10
      } else if indexPath.row > 3 {
        width += 30
      }
      
      return CGSize(width: width, height: 25)
    } else if collectionView == personCollectionView {
      let text = themePersonList[indexPath.row].rawValue
      let width = textWidth(text: text, font: UIFont.systemFont(ofSize: 12, weight: .medium))
      return CGSize(width: width + 24, height: 25)
    } else if collectionView == toolCollectionView {
      let text = themeToolList[indexPath.row].rawValue
      let width = textWidth(text: text, font: UIFont.systemFont(ofSize: 12, weight: .medium))
      return CGSize(width: width + 24, height: 25)
    } else if collectionView == activityCollectionView {
      let text = themeActivityList[indexPath.row].rawValue
      let width = textWidth(text: text, font: UIFont.systemFont(ofSize: 12, weight: .medium))
      return CGSize(width: width + 24, height: 25)
    } else {
      let text = indexPath.row == 0 ? "ON" : "OFF"
      let width = textWidth(text: text, font: UIFont.systemFont(ofSize: 12, weight: .medium))
      return CGSize(width: width + 24, height: 25)
    }
  }
  
}
