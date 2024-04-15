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
  
  @IBOutlet var gradeLabel: UILabel!
  
  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var contentLabel: UILabel!
  
  @IBOutlet var dateLabel: UILabel!
  
  @IBOutlet var gradeView: UIView!
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
    
    switch list.grade{
    case "0":
      gradeLabel.text = "0+"
    case "1":
      gradeLabel.text = "1+"
    case "2":
      gradeLabel.text = "11+"
    case "3":
      gradeLabel.text = "51+"
    case "4":
      gradeLabel.text = "101+"
    case "5":
      gradeLabel.text = "301+"
    case "6":
      gradeLabel.text = "301+"
    case "7":
      gradeLabel.text = "501+"
    case "8":
      gradeLabel.text = "1001+"
    default:
      gradeLabel.text = "none"
    }
    nameLabel.text = list.nickname
    dateLabel.text = list.createdAt
    deleteButton.isHidden = Int(list.user_pk) != DataHelperTool.userAppId ?? 0
    contentLabel.text = list.deletedAt != nil ? "삭제된 댓글입니다." : list.content
    contentLabel.changeTextBoldStyle(changeText: "삭제된 댓글입니다.", fontSize: 11)
    if list.deletedAt != nil{
      nameLabel.isHidden = true
      gradeView.isHidden = true
      replyButton.isHidden = true
      dateLabel.isHidden = true
      deleteButton.isHidden = true
    }
    
  }
  
 
  
  
  
  
}
