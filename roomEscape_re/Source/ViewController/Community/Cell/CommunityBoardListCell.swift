//
//  CommunityBoardListCell.swift
//  room_escape
//
//  Created by hoonKim on 2021/06/13.
//  Copyright © 2021 park. All rights reserved.
//

import UIKit

class CommunityBoardListCell: UITableViewCell {
  @IBOutlet var gradeView: UIView!
  @IBOutlet var gradeImageView: UIImageView!
  
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var contentLabel: UILabel!
  @IBOutlet var realContent: UILabel!
  
  @IBOutlet var aView: UIView!
  @IBOutlet var aImageView: UIImageView!
  
  @IBOutlet var recruitImageView: UIImageView!
  @IBOutlet var infoDiffImageView: UIImageView!
  
  @IBOutlet var dateLabel: UILabel!
  @IBOutlet var commentCountLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func initWithBoardList(_ list: BoardList, _ isMain: Bool? = nil) {
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
    
    
    titleLabel.text = list.nickname
    contentLabel.text = (isMain ?? false) ? "[\(list.diff.rawValue)] \(list.title)" : list.title
    realContent.text = list.content
    
    dateLabel.text = list.createdAt
    commentCountLabel.text = "댓글 \(list.commentCount)"
    
    aView.isHidden = list.category != "공지"
    gradeView.isHidden = list.category == "공지"
    switch list.diff {
      case .자유게시판:
        recruitImageView.isHidden = true
        infoDiffImageView.isHidden = list.category != "공지"
        
        infoDiffImageView.image = #imageLiteral(resourceName: "infoDiffIcon5")
      case .보드판갤러리:
        recruitImageView.isHidden = true
        infoDiffImageView.isHidden = true
      case .일행구하기:
        recruitImageView.isHidden = list.category == "공지"
        infoDiffImageView.isHidden = list.category != "공지"
          
        recruitImageView.image = list.category == "모집중" ? #imageLiteral(resourceName: "recruitImage") : #imageLiteral(resourceName: "finishRecruitImage")
        infoDiffImageView.image = #imageLiteral(resourceName: "infoDiffIcon5")
      case .방탈출정보:
        recruitImageView.isHidden = true
        infoDiffImageView.isHidden = false
      
        if list.category == "정보" {
          infoDiffImageView.image = #imageLiteral(resourceName: "infoDiffIcon1")
        } else if list.category == "소식" {
          infoDiffImageView.image = #imageLiteral(resourceName: "infoDiffIcon2")
        } else if list.category == "이벤트" {
          infoDiffImageView.image = #imageLiteral(resourceName: "infoDiffIcon3")
        } else if list.category == "후기" {
          infoDiffImageView.image = #imageLiteral(resourceName: "infoDiffIcon4")
        } else {
          infoDiffImageView.image = #imageLiteral(resourceName: "infoDiffIcon5")
        }
    }
  }
  
  
}
