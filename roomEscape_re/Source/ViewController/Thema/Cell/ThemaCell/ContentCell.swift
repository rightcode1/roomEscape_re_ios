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
  @IBOutlet weak var categoryLabel: UILabel!
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
  func initRankingList(index: Int,_ data: ThemaListData) {
    premiumImageView.isHidden = true
    if index == 0{
      premiumImageView.image = UIImage(named: "ranking1")
      premiumImageView.isHidden = false
    }else if index == 1{
      premiumImageView.image = UIImage(named: "ranking2")
      premiumImageView.isHidden = false
    }else if index == 2{
      premiumImageView.image = UIImage(named: "ranking3")
      premiumImageView.isHidden = false
    }
    contentImageView.kf.setImage(with: URL(string: "\(data.thumbnail ?? "")"))
    
    newImageView.isHidden = !data.typeNew
    differentImageView.isHidden = !data.typeDifferent
    newDiffBackView.isHidden = !(data.typeDifferent || data.typeNew)
    
    titleLabel.text = "\(data.title)"
    categoryLabel.text = "\(data.category)"
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
  
  func initContentList(_ data: ThemaListData) {
     
    contentImageView.kf.setImage(with: URL(string: "\(data.thumbnail ?? "")"))
    
    
    newDiffBackView.isHidden = !(data.typeDifferent || data.typeNew)
    newImageView.isHidden = !data.typeNew
    differentImageView.isHidden = !data.typeDifferent
    
    
    titleLabel.text = "\(data.title)"
    categoryLabel.text = "\(data.category)"
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
    
    
    newImageView.isHidden = !data.typeNew
    differentImageView.isHidden = !data.typeDifferent
    newDiffBackView.isHidden = !(data.typeDifferent || data.typeNew)
    
    
    titleLabel.text = "\(data.title)"
    categoryLabel.text = "\(data.category)"
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


