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
  @IBOutlet var collectionHeight: NSLayoutConstraint!
  
  var delegate: SortFilterDelegate?
  var pointOrigin: CGPoint?
  var selectSort: String = "최신순"
  var sortList: [String] = ["최신순","기록순","평점순","추천순"]
  var diff: Bool = false
  var hasSetPointOrigin = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if diff {
      sortList = ["최신순","평점순","추천순"]
    }
    sortCollectionView.delegate = self
    sortCollectionView.dataSource = self
    sortCollectionView.collectionViewLayout = CollectionViewLeftAlignFlowLayout()
    if let flowLayout = sortCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
              flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    }
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


extension SortFilterViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if sortList.count > 4{
      collectionHeight.constant = CGFloat(70)
    }
    return sortList.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = sortCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    guard let titleView = cell.viewWithTag(1) as? UIView else {
      return cell
    }
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
    titleLabel.textColor = isSame ? colorFromRGB(0xffa200) : colorFromRGB(0xaaaaaa)

    
    titleView.layer.cornerRadius = 5
    titleView.layer.masksToBounds = true
    titleView.backgroundColor = isSame ? colorFromRGB(0xffefbc) : colorFromRGB(0xffffff)
    titleView.layer.borderWidth = isSame ? 0 : 1
    titleView.layer.borderColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1.0).cgColor
    
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    selectSort = sortList[indexPath.row]
    sortCollectionView.reloadData()
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let text = sortList[indexPath.row]
    let width = textWidth(text: text, font: UIFont.systemFont(ofSize: 12, weight: .medium))
    return CGSize(width: width + 24, height: 25)
  }
  
}
class CollectionViewLeftAlignFlowLayout: UICollectionViewFlowLayout {
    let cellSpacing: CGFloat = 10
 
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        self.minimumLineSpacing = 10.0
        self.sectionInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        let attributes = super.layoutAttributesForElements(in: rect)
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            layoutAttribute.frame.origin.x = leftMargin
            leftMargin += layoutAttribute.frame.width + cellSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }
        return attributes
    }
}
