//
//  ReviewCell.swift
//  roomEscape_re
//
//  Created by hoon Kim on 2022/02/03.
//

import UIKit
import Cosmos
import Alamofire
import SwiftyJSON

protocol ReviewCellMyButtonsDelegate: AnyObject {
  func didUpdateButtonTapped(_ index: IndexPath)
  
  func didRemoveButtonTapped(_ index: IndexPath)
}

class ReviewCell: UITableViewCell {
  
  @IBOutlet var commentContentView: UIView!
  @IBOutlet var commentView: UIView!
  @IBOutlet var commentLabel: UILabel!
  @IBOutlet var commentContent: UILabel!
  
  @IBOutlet weak var gradeImageView: UIImageView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  
  @IBOutlet weak var ratingView: CosmosView!
  @IBOutlet weak var ratingLabel: UILabel!
  @IBOutlet weak var rateview: UIView!
  
  @IBOutlet weak var difficultyStackView: UIStackView!
  @IBOutlet weak var successLabel: UILabel!
  @IBOutlet weak var timeAndHintLabel: UILabel!
  
  @IBOutlet weak var contentLabel: UILabel!
  
  @IBOutlet weak var likeButton: UIButton!
  @IBOutlet var reportview: UIView!
  
  @IBOutlet weak var isMineView: UIView!
  @IBOutlet weak var updateButton: UIButton!
  @IBOutlet weak var removeButton: UIButton!
  
  @IBOutlet weak var lineView: UIView!
  
  var reviewid: Int = 0
  var isLike: Bool = false
  var likecount :Int = 0
  weak var delegate: ReviewCellMyButtonsDelegate?
  
  var index: IndexPath?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    ratingView.isUserInteractionEnabled = false
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
  }
  
  @IBAction func tapLikeButton(_ sender: Any) {
    reviewLike(reviewid)
      if self.isLike {
        self.isLike = false
        self.likecount-=1
        self.likeButton.setImage(UIImage(named: "reviewLikeButtonOff"), for: .normal)
        self.likeButton.setTitle("\(self.likecount)", for: .normal)
      }else{
        self.isLike = true
        self.likeButton.setImage(UIImage(named: "reviewLikeButtonOn"), for: .normal)
        self.likecount+=1
        self.likeButton.setTitle("\(self.likecount)", for: .normal)
      }
  }
  @IBAction func updateButtonTapped(_ sender: Any) {
    delegate?.didUpdateButtonTapped(index!)
  }
  
  @IBAction func removeButtonTapped(_ sender: Any) {
    print("!!!!!!")
    delegate?.didRemoveButtonTapped(index!)
  }
  
  func initWithCompanyReview(_ data: CompanyReview) {
    userNameLabel.text = data.userName
    dateLabel.text = data.createdAt
    ratingView.settings.fillMode = .half
    ratingView.rating = data.grade
    ratingLabel.text = "\(data.grade)"
    contentLabel.text = data.contents
  }
  
  func initWithThemeReview(_ data: ThemeReview,_ index: IndexPath) {
    if data.userId == DataHelperTool.userAppId{
      reportview.isHidden = true
    }else{
      reportview.isHidden = false
    }
    reviewid = data.id
    if (data.comments?.count == 0){
      commentView.isHidden = true
      commentContentView.isHidden = true
    }else{
      commentLabel.text = data.company?.title
      commentContent.text = data.comments?[0].content
    }
    isLike = data.isLike
    if isLike{
      likeButton.setImage(UIImage(named: "reviewLikeButtonOn"), for: .normal)
    }else{
      likeButton.setImage(UIImage(named: "reviewLikeButtonOff"), for: .normal)
    }
    likecount = data.likeCount
    likeButton.setTitle("\(likecount)", for: .normal)
    difficultyStackView.arrangedSubviews[0].isHidden = data.level != .매우쉬움
    difficultyStackView.arrangedSubviews[1].isHidden = data.level != .쉬움
    difficultyStackView.arrangedSubviews[2].isHidden = data.level != .보통
    difficultyStackView.arrangedSubviews[3].isHidden = data.level != .어려움
    difficultyStackView.arrangedSubviews[4].isHidden = data.level != .매우어려움
    
    userNameLabel.text = data.userName
    dateLabel.text = data.createdAt
    
    if data.grade == 0.0 {
      rateview.isHidden = true
      
    }else{
      ratingView.settings.fillMode = .half
      rateview.isHidden = false
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
    
    if data.grade == 1{
      self.gradeImageView.image = UIImage(named: "userLevelImage1")
    }else if data.grade == 2{
      self.gradeImageView.image = UIImage(named: "userLevelImage2")
    }else if data.grade == 3{
      self.gradeImageView.image = UIImage(named: "userLevelImage3")
    }else if data.grade == 4{
      self.gradeImageView.image = UIImage(named: "userLevelImage4")
    }else if data.grade == 5{
      self.gradeImageView.image = UIImage(named: "userLevelImage5")
    }else if data.grade == 6{
      self.gradeImageView.image = UIImage(named: "userLevelImage6")
    }else if data.grade == 7{
      self.gradeImageView.image = UIImage(named: "userLevelImage7")
    }else if data.grade == 8{
      self.gradeImageView.image = UIImage(named: "userLevelImage8")
    }
    contentLabel.text = data.content
  }
  
  func reviewLike(_ reviewId: Int){
    let apiurl = "/v1/themeReviewLike/register"
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiurl)")!
    let requestURL = url
    var request = URLRequest(url: requestURL)
    
    let param : reviewLikeRequest
    param = reviewLikeRequest(themeReviewId: reviewId)
    
    request.httpMethod = HTTPMethod.post.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try! JSONSerialization.data(withJSONObject: param.dictionary ?? [:], options: .prettyPrinted)
    AF.request(request).responseJSON { (response) in
      switch response.result {
      case .success(let value):
        let decoder = JSONDecoder()
        let json = JSON(value)
        let jsonData = try? json.rawData()
        print("\(apiurl) responseJson: \(requestURL)")
        print("\(apiurl) responseJson: \(json)")
        
        if let data = jsonData, let value = try? decoder.decode(DefaultResponse.self, from: data) {
          if value.statusCode == 200 {
        }
        
        break
      }
      case .failure(_):
        
        print("error: \(response.error!)")
        break
      }
  }
  }
  
}
