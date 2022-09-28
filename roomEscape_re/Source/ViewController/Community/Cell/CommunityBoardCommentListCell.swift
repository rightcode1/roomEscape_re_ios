//
//  CommunityBoardCommentListCell.swift
//  room_escape
//
//  Created by hoonKim on 2021/06/20.
//  Copyright © 2021 park. All rights reserved.
//

import UIKit

class CommunityBoardCommentListCell: UITableViewCell {
  @IBOutlet var leadingCons: NSLayoutConstraint!
  
  @IBOutlet var gradeImageView: UIImageView!
  
  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var contentLabel: UILabel!
  
  @IBOutlet var dateLabel: UILabel!
  
  @IBOutlet var replyButton: UIButton!
  @IBOutlet var deleteButton: UIButton!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
 
  func initWithCommentList(_ list: BoardCommentList) {
    leadingCons.constant = list.depth == "0" ? 15 : 50
    replyButton.isHidden = list.depth != "0"
    
    switch list.grade {
    case "0":
      gradeImageView.image = UIImage(named: "BigLevel0")
    case "1":
      gradeImageView.image = UIImage(named: "BigLevel1")
    case "2":
      gradeImageView.image = UIImage(named: "BigLevel2")
    case "3":
      gradeImageView.image = UIImage(named: "BigLevel3")
    case "4":
      gradeImageView.image = UIImage(named: "BigLevel4")
    case "5":
      gradeImageView.image = UIImage(named: "BigLevel5")
    case "6":
      gradeImageView.image = UIImage(named: "BigLevel6")
    case "7":
      gradeImageView.image = UIImage(named: "BigLevel7")
    default:
      gradeImageView.image = UIImage(named: "BigLevel8")
    }
    
    nameLabel.text = list.nickname
    contentLabel.text = list.content
    dateLabel.text = list.createdAt
    
//    deleteButton.isHidden = list.user_pk != userApp
  }
  
 
  
  
  
  
}
