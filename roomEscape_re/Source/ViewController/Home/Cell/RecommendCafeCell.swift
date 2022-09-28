//
//  RecommendCafeCollectionCell.swift
//  escapeRoom
//
//  Created by RightCode_IOS on 2021/12/06.
//

import UIKit
import Kingfisher
import Cosmos

class RecommendCafeCell: UICollectionViewCell {
  
  @IBOutlet weak var cafeFirstImageView: UIImageView!
  @IBOutlet weak var cafeSecondImageView: UIImageView!
  @IBOutlet weak var cafeThirdImageView: UIImageView!
  
  @IBOutlet weak var cafeImageStackView: UIStackView!
  @IBOutlet weak var cafeNameLabel: UILabel!
  @IBOutlet weak var cafeRatesLabel: UILabel!
  @IBOutlet weak var cafeFavoritesLabel: UILabel!
  
  @IBOutlet weak var wholePhotosView: UIView!
  
  @IBOutlet weak var cafeStarRatesView: CosmosView!
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
    wholePhotosView.layer.cornerRadius = 7.5
    cafeStarRatesView.settings.starMargin = 3
    cafeStarRatesView.isUserInteractionEnabled = false
  }

  func initWithOrderCountData(_ data: CompanyListData) {
    
    cafeFirstImageView.kf.setImage(with: URL(string: "\(data.thumbnail ?? "")")!)
    cafeImageStackView.isHidden = !(data.themeThumbnails.count >= 2)

    if data.themeThumbnails.count >= 2 {
      cafeSecondImageView.kf.setImage(with: URL(string: "\(data.themeThumbnails[0])")!)
      cafeThirdImageView.kf.setImage(with: URL(string: "\(data.themeThumbnails[1])")!)
    } else {
      cafeSecondImageView.kf.setImage(with: URL(string: "\(data.thumbnail ?? "")")!)
      cafeThirdImageView.kf.setImage(with: URL(string: "\(data.thumbnail ?? "")")!)
    }
    
    cafeNameLabel.text = data.title
    cafeRatesLabel.text = "\(data.averageRate)"
    cafeFavoritesLabel.text = "\(data.wishCount)"
    cafeRatesLabel.text = "\(data.averageRate)"
    cafeStarRatesView.rating = Double(data.averageRate)
    cafeFavoritesLabel.text = "\(data.wishCount)"

  }
}
