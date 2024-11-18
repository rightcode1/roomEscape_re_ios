//
//  ThemeReviewListCell.swift
//  roomEscape_re
//
//  Created by hoon Kim on 2022/02/23.
//

import UIKit
import Cosmos

class ThemeReviewListCell: UITableViewCell {
  @IBOutlet weak var themeImageView: UIImageView!
  @IBOutlet weak var themeNameLabel: UILabel!
  @IBOutlet weak var cafeNameLabel: UILabel!
  
  @IBOutlet weak var gradeLabel: UILabel!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  
  @IBOutlet weak var rateView: UIView!
  @IBOutlet weak var ratingView: CosmosView!
  @IBOutlet weak var ratingLabel: UILabel!
  
  @IBOutlet weak var difficultyStackView: UIStackView!
  @IBOutlet weak var successLabel: UILabel!
  @IBOutlet weak var timeAndHintLabel: UILabel!
  
  @IBOutlet weak var contentLabel: UILabel!
  
  @IBOutlet weak var likeButton: UIButton!
  @IBOutlet weak var reportButton: UILabel!
  
  @IBOutlet weak var isMineView: UIView!
  @IBOutlet weak var updateButton: UIButton!
  @IBOutlet weak var removeButton: UIButton!
  
  @IBOutlet weak var lineView: UIView!
  
  weak var delegate: ReviewCellMyButtonsDelegate?
  
  var index: IndexPath?
  var reviewId: Int?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    ratingView.isUserInteractionEnabled = false
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  @IBAction func likeButton(_ sender: Any) {
    
  }
  
  @IBAction func updateButtonTapped(_ sender: Any) {
    delegate?.didUpdateButtonTapped(index!)
  }
  
  @IBAction func removeButtonTapped(_ sender: Any) {
    print(index)
    delegate?.didRemoveButtonTapped(index!)
  }
  
  func initWithThemeReview(_ data: ThemeReview,_ index:IndexPath) {
    themeImageView.kf.setImage(with: URL(string: data.theme?.thumbnail ?? ""))
    themeNameLabel.text = data.theme?.title
    cafeNameLabel.text = data.theme?.companyName
    reviewId = data.id
    
    if (data.reviewCount >= 1 && data.reviewCount <= 10){
      self.gradeLabel.text = "1+"
    }else if(data.reviewCount >= 11 && data.reviewCount <= 50){
      self.gradeLabel.text = "11+"
    }else if(data.reviewCount >= 51 && data.reviewCount <= 100){
      self.gradeLabel.text = "51+"
    }else if(data.reviewCount >= 101 && data.reviewCount <= 200){
      self.gradeLabel.text = "101+"
    }else if(data.reviewCount >= 201 && data.reviewCount <= 300){
      self.gradeLabel.text = "201+"
    }else if(data.reviewCount >= 301 && data.reviewCount <= 500){
      self.gradeLabel.text = "301+"
    }else if(data.reviewCount >= 501 && data.reviewCount <= 1000){
      self.gradeLabel.text = "501+"
    }else if(data.reviewCount >= 1001){
      self.gradeLabel.text = "1001+"
    }else {
      self.gradeLabel.text = "0"
    }
    
    difficultyStackView.arrangedSubviews[0].isHidden = data.level != .매우쉬움
    difficultyStackView.arrangedSubviews[1].isHidden = data.level != .쉬움
    difficultyStackView.arrangedSubviews[2].isHidden = data.level != .보통
    difficultyStackView.arrangedSubviews[3].isHidden = data.level != .어려움
    difficultyStackView.arrangedSubviews[4].isHidden = data.level != .매우어려움
    
    ratingView.settings.fillMode = .half
    userNameLabel.text = data.userName
    dateLabel.text = data.playDate
    if data.grade == 0.0 {
      rateView.isHidden = true
      
    }else{
      rateView.isHidden = false
      ratingView.rating = data.grade
      ratingLabel.text = "\(data.grade)"
    }
    
    self.index = index
    
    successLabel.text = data.success.rawValue
    

    
    if data.userHint == nil && data.extraTime == nil{
      timeAndHintLabel.text = ""
    }else if data.userHint == nil{
      
      if DataHelperTool.playTimeType == "걸린시간" {
        let time = data.remainingTime?.components(separatedBy: ":")
        timeAndHintLabel.text = "걸린 시간 : \(time?[0] ?? "")분\(time?[1] ?? "")초"
        
      }else{
        let time = data.extraTime?.components(separatedBy: ":")
        timeAndHintLabel.text = "남은 시간 : \(time?[0] ?? "")분\(time?[1] ?? "")초"
        
      }
    }else if data.extraTime == nil{
      timeAndHintLabel.text = " 사용 힌트 수 : \(data.userHint ?? 0)"
    }else{
      if DataHelperTool.playTimeType == "걸린시간" {
        let time = data.remainingTime?.components(separatedBy: ":")
        timeAndHintLabel.text = "걸린 시간 : \(time?[0] ?? "")분\(time?[1] ?? "")초  사용 힌트 수 : \(data.userHint ?? 0)"
        
      }else{
        let time = data.extraTime?.components(separatedBy: ":")
        timeAndHintLabel.text = "남은 시간 : \(time?[0] ?? "")분\(time?[1] ?? "")초  사용 힌트 수 : \(data.userHint ?? 0)"
        
      }
    }
    
    
    contentLabel.text = data.content
  }
  
}
