//
//  File.swift
//  roomEscape_re
//
//  Created by 이남기 on 2022/04/29.
//

import UIKit

class EventCell: UITableViewCell {
    @IBOutlet weak var Thumbnail: UIImageView!
    @IBOutlet weak var Title: UILabel!
    @IBOutlet weak var event: UIImageView!
    @IBOutlet weak var date: UILabel!

    
  override func awakeFromNib() {
    super.awakeFromNib()
      
      Thumbnail.layer.cornerRadius = 15
    

    
  }
  
}
