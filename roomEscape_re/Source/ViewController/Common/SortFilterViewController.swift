//
//  SortFilterViewController.swift
//  roomEscape_re
//
//  Created by 이남기 on 2022/09/14.
//

import Foundation
import UIKit

protocol SortFilterDelegate {
  func setFilter(sort: String)
}


class SortFilterViewController: UIViewController {
  @IBOutlet weak var backView: UIView!
  
  @IBOutlet var sortCollectionView: UICollectionView!
  
  var delegate: SortFilterDelegate?
  var pointOrigin: CGPoint?
  var selectSort: String = "최신순"
  var sortList: [String] = []
  var diff: Bool = false
  var hasSetPointOrigin = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if diff {
      sortList = ["최신순","평점순","추천순"]
    }else{
      sortList = ["최신순","기록순","평점순","추천순"]
    }
    sortCollectionView.delegate = self
    sortCollectionView.dataSource = self
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
    view.addGestureRecognizer(panGesture)
    
    backView.roundCorners([.topLeft, .topRight], radius: 25)
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
  
  func textWidth(text: String, font: UIFont?) -> CGFloat {
    let attributes = font != nil ? [NSAttributedString.Key.font: font] : [:]
    return text.size(withAttributes: attributes as [NSAttributedString.Key : Any]).width
  }
  
  @IBAction func tapSaveFilter(_ sender: UIButton) {
    delegate?.setFilter(sort: selectSort)
    backPress()
  }
  
}


extension SortFilterViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return sortList.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = sortCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    
    guard let titleLabel = cell.viewWithTag(2) as? UILabel else {
      return cell
    }
    
    let diff = sortList[indexPath.row]
    var isSame = false
    for count in 0..<sortList.count{
      isSame = sortList[indexPath.row] == selectSort
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
  }
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    selectSort = sortList[indexPath.row]
    sortCollectionView.reloadData()
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    10
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    10
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let text = sortList[indexPath.row]
    let width = textWidth(text: text, font: UIFont.systemFont(ofSize: 12, weight: .medium))
    return CGSize(width: width + 24, height: 25)
  }
  
}
