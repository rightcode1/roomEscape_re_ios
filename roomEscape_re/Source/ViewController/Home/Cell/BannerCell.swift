//
//  BannerCollectionCell.swift
//  escapeRoom
//
//  Created by RightCode_IOS on 2021/12/06.
//

import UIKit

class BannerCell: UICollectionViewCell {
  
  @IBOutlet weak var bannerImageView: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    bannerImageView.layer.cornerRadius = 15
    
  }

  
}
