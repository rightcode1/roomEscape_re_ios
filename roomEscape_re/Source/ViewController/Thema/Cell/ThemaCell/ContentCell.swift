//
//  ContentTableViewCell.swift
//  roomEscape_re
//
//  Created by RightCode_IOS on 2021/12/08.
//

import UIKit
import Cosmos

class ContentCell: UITableViewCell {
  
  @IBOutlet weak var contentImageView: UIImageView!
  @IBOutlet weak var premiumImageView: UIImageView!
  
  @IBOutlet weak var newImageView: UIImageView!
  @IBOutlet weak var differentImageView: UIImageView!
  @IBOutlet weak var newDiffBackView: UIView!
  
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!
  @IBOutlet weak var starRatesView: CosmosView!
  @IBOutlet weak var starScoreLabel: UILabel!
  @IBOutlet weak var favoritesView: UIImageView!
  @IBOutlet weak var favoritesScoreLabel: UILabel!
  
  @IBOutlet weak var levelStackView: UIStackView!
  @IBOutlet weak var timeLabel: UILabel!
  
  @IBOutlet weak var featureLabel: UILabel!
  @IBOutlet weak var isWishButton: UIButton!
  
  
  @IBAction func isWishButtonPressed(_ sender: UIButton) {

  }
  
  weak var delegate: WishDelegate?
  
  var index: Int?
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  @IBAction func wishButtonTapped(_ sender: Any) {
    delegate?.didWishButtonTapped(index ?? 0)
  }

  func initLevelStackView(_ level: Int) {
    let hiddenCount = 5 - level
    
    for i in 0..<level {
      levelStackView.arrangedSubviews[i].isHidden = false
    }
    
    for i in 0..<hiddenCount {
      levelStackView.arrangedSubviews[4-i].isHidden = true
    }
  }
  
  func initContentList(_ data: ThemaListData) {
     
    contentImageView.kf.setImage(with: URL(string: "\(data.thumbnail ?? "")"))
    
    if data.typeNew == false {
      newImageView.isHidden = true
      newDiffBackView.isHidden = true
    } else {
      newImageView.isHidden = false
    }
    
    if data.typeDifferent == false {
      differentImageView.isHidden = true
      newDiffBackView.isHidden = true
    } else {
      differentImageView.isHidden = false
    }
    
    titleLabel.text = "\(data.title)  \(data.category)"
//    conceptLabel.text = data.category
    locationLabel.text = data.companyName
    starRatesView.settings.fillMode = .half

    starRatesView.rating = Double(data.grade)
    starScoreLabel.text = "\(data.grade)"
    favoritesScoreLabel.text = "\(data.wishCount)"
    
    initLevelStackView(data.level)
    
    timeLabel.text = "\(data.time)분"
    featureLabel.text = "활동성 \(data.activity) • 장치비율 \(data.tool) • \(data.recommendPerson)인 이상"
    
    let wishImage = data.isWish ? UIImage(named: "isWishFull") : UIImage(named: "isWishEmpty")
    isWishButton.setImage(wishImage, for: .normal)
  }
  func initPremiumThemeList(_ data: ThemaListData,_ premiumSize: Int,_ index: Int) {
    if premiumSize < index+1{
      premiumImageView.isHidden = true
    }else{
      premiumImageView.isHidden = false
    }
     
    contentImageView.kf.setImage(with: URL(string: "\(data.thumbnail ?? "")"))
    
    if data.typeNew == false {
      newImageView.isHidden = true
      newDiffBackView.isHidden = true
    } else {
      newImageView.isHidden = false
    }
    
    if data.typeDifferent == false {
      differentImageView.isHidden = true
      newDiffBackView.isHidden = true
    } else {
      differentImageView.isHidden = false
    }
    
    titleLabel.text = "\(data.title)  \(data.category)"
//    conceptLabel.text = data.category
    locationLabel.text = data.companyName
    starRatesView.settings.fillMode = .half

    starRatesView.rating = Double(data.grade)
    starScoreLabel.text = "\(data.grade)"
    favoritesScoreLabel.text = "\(data.wishCount)"
    
    initLevelStackView(data.level)
    
    timeLabel.text = "\(data.time)분"
    featureLabel.text = "활동성 \(data.activity) • 장치비율 \(data.tool) • \(data.recommendPerson)인 이상"
    
    let wishImage = data.isWish ? UIImage(named: "isWishFull") : UIImage(named: "isWishEmpty")
    isWishButton.setImage(wishImage, for: .normal)
  }
}
