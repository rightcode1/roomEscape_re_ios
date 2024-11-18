//
//  CommunityBoardListCell.swift
//  room_escape
//
//  Created by hoonKim on 2021/06/13.
//  Copyright © 2021 park. All rights reserved.
//

import UIKit

class CommunityBoardListCell: UITableViewCell {
  @IBOutlet var gradeLabel: UILabel!
  
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var contentLabel: UILabel!
  @IBOutlet var nickNameLabel: UILabel!
  
  @IBOutlet var themaImageView: UIImageView!
  @IBOutlet var themaTitleLabel: UILabel!
  @IBOutlet var themaDiffLabel: UILabel!
  @IBOutlet var themaCompanyNameLabel: UILabel!
  
  @IBOutlet var infoCategoryImageView: UIImageView!
  @IBOutlet var infoWidth: NSLayoutConstraint!
  
  @IBOutlet var dateLabel: UILabel!
  @IBOutlet var commentCountLabel: UILabel!
  
  @IBOutlet var themaView: UIView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  override func prepareForReuse() {
          super.prepareForReuse()
    gradeLabel.text = "0+"
    infoCategoryImageView.isHidden = false
    infoCategoryImageView.image = #imageLiteral(resourceName: "infoDiffIcon5")
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func initWithBoardList(_ list: BoardList, _ isMain: Bool? = nil) {
    titleLabel.text = list.title
    nickNameLabel.text = list.nickname
    contentLabel.text = list.content
    
    dateLabel.text = list.createdAt
    commentCountLabel.text = "댓글 \(list.commentCount)"
    
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
      gradeLabel.text = "201+"
    case "6":
      gradeLabel.text = "301+"
    case "7":
      gradeLabel.text = "501+"
    case "8":
      gradeLabel.text = "1001+"
    default:
      gradeLabel.text = "0"
    }
    
    switch list.category {
    case "공지":
      infoCategoryImageView.image = #imageLiteral(resourceName: "infoDiffIcon5")
    case "정보":
      infoCategoryImageView.image = #imageLiteral(resourceName: "infoDiffIcon1")
    case "소식":
      infoCategoryImageView.image = #imageLiteral(resourceName: "infoDiffIcon2")
    case "이벤트":
      infoCategoryImageView.image = #imageLiteral(resourceName: "infoDiffIcon3")
    case "후기":
      infoCategoryImageView.image = #imageLiteral(resourceName: "infoDiffIcon4")
    case "모집중":
      infoCategoryImageView.image = #imageLiteral(resourceName: "recruitImage")
    case "모집완료":
      infoCategoryImageView.image = #imageLiteral(resourceName: "finishRecruitImage")
    case "진행":
      infoCategoryImageView.image = #imageLiteral(resourceName: "infoDiffIcon6")
    case "마감":
      infoCategoryImageView.image = #imageLiteral(resourceName: "infoDiffIcon7")
    default:
      infoCategoryImageView.isHidden = true
      break
    }
    let scale = (infoCategoryImageView.image?.size.width ?? 0) / (infoCategoryImageView.image?.size.height ?? 0)
    infoWidth.constant = 15 * scale
    if list.theme != nil{
      themaView.isHidden = false
      themaImageView.kf.setImage(with: URL(string: "\(list.theme?.thumbnail ?? "")"))
      themaDiffLabel.text = list.theme?.category
      themaTitleLabel.text = list.theme?.title
      themaCompanyNameLabel.text = list.theme?.companyName
    }else{
      themaView.isHidden = true
    }
  }
  
  
}
