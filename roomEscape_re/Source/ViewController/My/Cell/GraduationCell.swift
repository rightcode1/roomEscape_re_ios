//
//  GraduationCell.swift
//  roomEscape_re
//
//  Created by 이남기 on 2022/10/17.
//

import Foundation
import UIKit

class GraduationCell: UITableViewCell{
  
  @IBOutlet var companyThumbnail: UIImageView!
  @IBOutlet var compantName: UILabel!
  @IBOutlet var companyLikeCount: UILabel!
  @IBOutlet var companyWishCount: UILabel!
  @IBOutlet var backView: UIView!
  
  var themes : [Themes] = []
  
  @IBOutlet var subTableView: UITableView!
  
  func initdelegate(data: GraduationCompanyListData){
    
    backView?.layer.applySketchShadow(color: UIColor(red: 117, green: 117, blue: 117), alpha: 0.16, x: 0, y: 1.5, blur: 5, spread: 0)
    backView?.layer.cornerRadius  = 10
    companyThumbnail.kf.setImage(with: URL(string: data.thumbnail ?? ""))
    compantName.text = data.title
    companyLikeCount.text = "\(data.averageRate) (\(data.reviewCount))"
    companyWishCount.text = "\(data.wishCount)"
    
    subTableView.dataSource = self
    subTableView.delegate = self
    
    themes = data.themes
    subTableView.reloadData()
  }
  
}
extension GraduationCell: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return themes.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let dict = themes[indexPath.row]
    guard let check = cell.viewWithTag(1) as? UIImageView,
          let name = cell.viewWithTag(2) as? UILabel else {
            return cell
          }
    check.isHidden = !dict.isSuccess
    name.text = dict.title
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
}
