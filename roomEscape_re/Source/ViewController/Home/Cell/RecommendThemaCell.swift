//
//  RecommendThemaCollectionCell.swift
//  escapeRoom
//
//  Created by RightCode_IOS on 2021/12/06.
//

import UIKit
import Cosmos

class RecommendThemaCell: UICollectionViewCell {
  
  @IBOutlet weak var themaImageView: UIImageView!
  @IBOutlet weak var themaNameLabel: UILabel!
  @IBOutlet weak var themaConceptLabel: UILabel!
  @IBOutlet weak var themaLocationLabel: UILabel!
  @IBOutlet weak var themaRatesLabel: UILabel!
  @IBOutlet weak var themaStarRatesView: CosmosView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    self.themaImageView.layer.cornerRadius = 8
    themaStarRatesView.rating = 4
    themaStarRatesView.settings.starMargin = 3
  }

  func initWithOrderCountData(_ data: ThemaListData) {
    themaImageView.kf.setImage(with: URL(string: "\(data.thumbnail ?? "")"))
    themaNameLabel.text = data.title
    themaConceptLabel.text = data.category
    themaLocationLabel.text = data.companyName
    themaRatesLabel.text = "\(data.grade)"
    themaStarRatesView.rating = Double(data.grade)
  }
  
}
