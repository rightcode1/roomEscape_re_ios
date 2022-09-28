//
//  CafeFilterPopupVC.swift
//  roomEscape_re
//
//  Created by hoon Kim on 2022/02/01.
//

import UIKit

protocol CafeFilterDelegate {
  func selectedFilter(sort: CafeSortDiff, typeList: [CafeTypeDiff])
}

class CafeFilterPopupVC: UIViewController {
  
  @IBOutlet weak var sortCollectionView: UICollectionView!
  @IBOutlet weak var typeCollectionView: UICollectionView!
  
  let sortList: [CafeSortDiff] = [.전방추천순, .리뷰많은순, .평점높은순, .거리순]
  var selectedSort: CafeSortDiff = .전방추천순
  
  let typeList: [CafeTypeDiff] = [.new, .different, .only, .foreign]
  var selectedTypeList: [CafeTypeDiff] = []
  
  var delegate: CafeFilterDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    sortCollectionView.reloadData()
    typeCollectionView.reloadData()
  }
  
  // String의 width 구하는 함수
  func textWidth(text: String, font: UIFont?) -> CGFloat {
    let attributes = font != nil ? [NSAttributedString.Key.font: font] : [:]
    return text.size(withAttributes: attributes as [NSAttributedString.Key : Any]).width
  }
  
  @IBAction func tapSave(_ sneder: UIButton) {
    backPress()
    delegate?.selectedFilter(sort: selectedSort, typeList: selectedTypeList)
  }
  
}

extension CafeFilterPopupVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
 
 func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
   if collectionView == sortCollectionView {
     return sortList.count
   } else {
     return typeList.count
   }
 }
 
 func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
   if collectionView == sortCollectionView {
     let cell = sortCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
     
     guard let titleLabel = cell.viewWithTag(2) as? UILabel else {
       return cell
     }
     
     let diff = sortList[indexPath.row].rawValue
     let isSame = sortList[indexPath.row] == selectedSort
     
     titleLabel.text = diff
     
     titleLabel.layer.cornerRadius = 5
     titleLabel.layer.masksToBounds = true
     titleLabel.textColor = isSame ? colorFromRGB(0xffa200) : colorFromRGB(0xaaaaaa)
     titleLabel.backgroundColor = isSame ? colorFromRGB(0xffefbc) : colorFromRGB(0xffffff)
     titleLabel.layer.borderWidth = isSame ? 0 : 1
     titleLabel.layer.borderColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1.0).cgColor
     
     return cell
   } else {
     let cell = typeCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
     
     guard let titleLabel = cell.viewWithTag(1) as? UILabel else {
       return cell
     }
     
     let diff = typeList[indexPath.row].rawValue
     let isSame = selectedTypeList.contains(typeList[indexPath.row])
     
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
     selectedSort = sortList[indexPath.row]
     sortCollectionView.reloadData()
     
   } else {
     let type = typeList[indexPath.row]
       if selectedTypeList.contains(type) {
         selectedTypeList.remove(type)
       } else {
         selectedTypeList.append(type)
       }
       
       typeCollectionView.reloadData()
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
     let diff = sortList[indexPath.row].rawValue
     let text = diff
     let width = textWidth(text: text, font: UIFont.systemFont(ofSize: 13, weight: .medium))
     return CGSize(width: width + 24, height: 25)
   } else {
     let dict = typeList[indexPath.row]
     let text = dict.rawValue
     let width = textWidth(text: text, font: UIFont.systemFont(ofSize: 13, weight: .medium))
     return CGSize(width: width + 24, height: 25)
   }
 }
 
}
