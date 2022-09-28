//
//  LevelMenuVC.swift
//  roomEscape_re
//
//  Created by 이남기 on 2022/07/11.
//

import Foundation
import UIKit

class LevelMenuVC:BaseViewController{
  
  @IBOutlet var levelImageView: UIImageView!
  @IBOutlet var levelLabel: UILabel!
  @IBOutlet var reviewCountLabel: UILabel!
  
  var reviewCount :Int = 0
  
  
  override func viewDidLoad() {
    self.levelLabel.text = "\(reviewCount)회 작성"
    if (reviewCount >= 0 && reviewCount <= 10){
      self.levelImageView.image = #imageLiteral(resourceName: "BigLevel1")
      self.reviewCountLabel.text = "1~10회"
    }else if(reviewCount >= 11 && reviewCount <= 50){
      self.levelImageView.image = #imageLiteral(resourceName: "BigLevel2")
      self.reviewCountLabel.text = "11~50회"
    }else if(reviewCount >= 51 && reviewCount <= 100){
      self.levelImageView.image = #imageLiteral(resourceName: "BigLevel3")
      self.reviewCountLabel.text = "51~100회"
    }else if(reviewCount >= 101 && reviewCount <= 200){
      self.levelImageView.image = #imageLiteral(resourceName: "BigLevel4")
      self.reviewCountLabel.text = "101~200회"
    }else if(reviewCount >= 201 && reviewCount <= 300){
      self.levelImageView.image = #imageLiteral(resourceName: "BigLevel5")
      self.reviewCountLabel.text = "201~300회"
    }else if(reviewCount >= 301 && reviewCount <= 500){
      self.levelImageView.image = #imageLiteral(resourceName: "BigLevel6")
      self.reviewCountLabel.text = "301~500회"
    }else if(reviewCount >= 501 && reviewCount <= 1000){
      self.levelImageView.image = #imageLiteral(resourceName: "BigLevel7")
      self.reviewCountLabel.text = "501~1000회"
    }else {
      self.levelImageView.image = #imageLiteral(resourceName: "BigLevel8")
      self.reviewCountLabel.text = "1001회~"
    }
  }
  
}
