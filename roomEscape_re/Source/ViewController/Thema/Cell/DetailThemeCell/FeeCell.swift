//
//  FeeCell.swift
//  roomEscape_re
//
//  Created by RightCode_IOS on 2021/12/10.
//

import UIKit

class FeeCell: UITableViewCell {
  
  @IBOutlet weak var perPeople: UILabel!
  @IBOutlet weak var perFee: UILabel!
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  func initWithThemePrice(_ data: ThemePrice) {
    perPeople.text = data.title
    perFee.text = "\(data.price.formattedProductPrice() ?? "0")원"
  }
  
}
