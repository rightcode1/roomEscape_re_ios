//
//  CafeListCell.swift
//  roomEscape_re
//
//  Created by hoon Kim on 2022/02/01.
//

import UIKit
import Cosmos

protocol WishDelegate: AnyObject {
  func didWishButtonTapped(_ index: Int)
}

class CafeListCell: UITableViewCell {
  
  @IBOutlet weak var cafeFirstImageView: UIImageView!
  
  @IBOutlet weak var cafePremiumImageView: UIImageView!
  @IBOutlet weak var cafeImageStackView: UIStackView!
  @IBOutlet weak var cafeSecondImageView: UIImageView!
  @IBOutlet weak var cafeThirdImageView: UIImageView!
  
  @IBOutlet weak var cafeNameLabel: UILabel!
  @IBOutlet weak var cafeRateLabel: UILabel!
  @IBOutlet weak var cafeFavoritesLabel: UILabel!
  @IBOutlet weak var isWishImageView: UIImageView!
  
  @IBOutlet weak var wholePhotosView: UIView!
  
  @IBOutlet weak var cafeStarRateView: CosmosView!
  
  weak var delegate: WishDelegate? 
  
  var index: Int?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    wholePhotosView.layer.cornerRadius = 7.5
    cafeStarRateView.settings.starMargin = 3
    cafeStarRateView.isUserInteractionEnabled = false
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
  }
  
  @IBAction func wishButtonTapped(_ sender: Any) {
    delegate?.didWishButtonTapped(index ?? 0)
  }
  
  func initWithCompanyListData(_ data: WishCompanyListData) {
    cafeFirstImageView.kf.setImage(with: URL(string: "\(data.thumbnail ?? "")")!)
    
    cafeImageStackView.isHidden = true
//    
//    if data.themeThumbnails.count >= 2 {
//      cafeSecondImageView.kf.setImage(with: URL(string: "\(data.themeThumbnails[0])")!)
//      cafeThirdImageView.kf.setImage(with: URL(string: "\(data.themeThumbnails[1])")!)
//    }
    
    cafeNameLabel.text = data.title
    cafeRateLabel.text = "\(data.averageRate) (\(data.reviewCount.formattedProductPrice() ?? "0"))"
    cafeFavoritesLabel.text = "\(data.wishCount)"
    
    isWishImageView.image = data.isWish ? UIImage(named: "isWishFull") : UIImage(named: "isWishEmpty")
    
    cafeStarRateView.settings.fillMode = .half
    cafeStarRateView.rating = Double(data.averageRate)
    cafeFavoritesLabel.text = "\(data.wishCount)"
    
  }
    func initCompanyListData(_ data: CompanyListData,_ premiumSize: Int,_ index: Int) {
      if premiumSize < index+1{
        cafePremiumImageView.isHidden = true
      }else{
        cafePremiumImageView.isHidden = false
      }
      
      cafeFirstImageView.kf.setImage(with: URL(string: "\(data.thumbnail ?? "")")!)
      
      cafeImageStackView.isHidden = !(data.themeThumbnails.count >= 2)
      
      if data.themeThumbnails.count >= 2 {
        cafeSecondImageView.kf.setImage(with: URL(string: "\(data.themeThumbnails[0])")!)
        cafeThirdImageView.kf.setImage(with: URL(string: "\(data.themeThumbnails[1])")!)
      }
      
      cafeNameLabel.text = data.title
      cafeRateLabel.text = "\(data.averageRate) (\(data.reviewCount.formattedProductPrice() ?? "0"))"
      cafeFavoritesLabel.text = "\(data.wishCount)"
      
      isWishImageView.image = data.isWish ? UIImage(named: "isWishFull") : UIImage(named: "isWishEmpty")
      cafeStarRateView.settings.fillMode = .half

      cafeStarRateView.rating = Double(data.averageRate)
      cafeFavoritesLabel.text = "\(data.wishCount)"
      
    }
}
