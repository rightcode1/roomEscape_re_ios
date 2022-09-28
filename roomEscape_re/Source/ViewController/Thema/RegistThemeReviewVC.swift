//
//  RegistThemeReviewVC.swift
//  roomEscape_re
//
//  Created by hoon Kim on 2022/02/03.
//

import UIKit
import Cosmos
import Alamofire
import SwiftyJSON

class RegistThemeReviewVC: UIViewController {
  @IBOutlet weak var notRateButton: UIButton!
  
  @IBOutlet weak var rateBackView: UIView!
  @IBOutlet weak var ratingView: CosmosView!
  
  @IBOutlet weak var playDateLabel: UILabel!
  @IBOutlet weak var difficultyCollectionView: UICollectionView!
  @IBOutlet weak var successCollectionView: UICollectionView!
  @IBOutlet weak var restTimeLabel: UILabel!
  @IBOutlet weak var hintCollectionView: UICollectionView!
  @IBOutlet weak var contentTextView: UITextView!
  
  var themeDetailData: ThemaDetailData!
  var reviewData: ThemeReview?
  
  var isRate: Bool = true
  
  var rating = 5.0
  
  var playDate: String?
  
  let difficultyList: [ReviewLavel] = [.매우쉬움, .쉬움, .보통, .어려움, .매우어려움]
  var selectedDifficulty: ReviewLavel = .매우쉬움
  var successDiff: [SuccessDiff] = [.성공, .실패]
  var selectedSuccessDiff: SuccessDiff = .성공
  
  var restTime: String?
  
  let hintCount: [Int] = [0, 1, 2, 3, 4, 5]
  var selectedHintCount: Int?
  
  var contentTextViewPlaceHolder: String = "후기 입력"
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.isNavigationBarHidden = false
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    contentTextView.delegate = self
    initPlayDateLabel()
    ratingView.settings.minTouchRating = 0.5
    ratingView.rating = 5.0
    ratingView.settings.fillMode = .half
    ratingView.didFinishTouchingCosmos = { rating in
      self.rating = rating
    }
    ratingView.didTouchCosmos = { rating in
      self.rating = rating
    }
    
    initWithReviewData()
    difficultyCollectionView.reloadData()
    successCollectionView.reloadData()
    hintCollectionView.reloadData()
  }
  func initWithReviewData() {
    if reviewData != nil {
      ratingView.rating = reviewData?.grade ?? 0.0
      rating = reviewData?.grade ?? 0.0
      selectedSuccessDiff = reviewData!.success
      selectedDifficulty = reviewData!.level
      if reviewData?.extraTime != nil{
        restTimeLabel.text = reviewData?.extraTime
        restTime = reviewData?.extraTime
      }
      playDate = reviewData?.playDate
      playDateLabel.text = reviewData?.playDate
      selectedHintCount = reviewData?.userHint
      contentTextView.text = reviewData!.content
      if reviewData!.grade == 0 {
        notRateButton.setTitleColor(colorFromRGB(0xffa200), for: .normal)
        notRateButton.backgroundColor = isRate ? colorFromRGB(0xffefbc) : colorFromRGB(0xffffff)
        ratingView.settings.updateOnTouch = false
      }
    }
  }
  
  func initPlayDateLabel() {
    let todayDateFormatter = DateFormatter()
    todayDateFormatter.dateFormat = "yyyy-MM-dd"
    playDate = todayDateFormatter.string(from: Date())
    playDateLabel.text = playDate
  }
  
  func textViewSetupView() {
    if contentTextView.text == contentTextViewPlaceHolder {
      contentTextView.text = ""
      contentTextView.textColor = .black
    } else if contentTextView.text.isEmpty {
      contentTextView.text = contentTextViewPlaceHolder
      contentTextView.textColor = UIColor.lightGray
    }
  }
  
  func moveToSelectDate() {
    let vc = UIStoryboard.init(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "selectDateVC") as! SelectCalendarDateViewController
    vc.delegate = self
    
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd"
    let selectDate = dateFormatter.date(from: playDate ?? "")!
    
    print("\(playDate)!!!!!!!!!!")
    print("\(selectDate)!!!!!!!!!!")
    vc.selectedDate = selectDate
    self.present(vc, animated: true, completion: nil)
  }
  
  func moveToCustomTimePicker() {
    let vc = UIStoryboard.init(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "timePick") as! CustomTimePickerViewController
    vc.delegate = self
    vc.minute = themeDetailData.time - 1
    self.present(vc, animated: true, completion: nil)
  }
  
  // String의 width 구하는 함수
  func textWidth(text: String, font: UIFont?) -> CGFloat {
    let attributes = font != nil ? [NSAttributedString.Key.font: font] : [:]
    return text.size(withAttributes: attributes as [NSAttributedString.Key : Any]).width
  }
  
  func regist() {
    self.showHUD()
    let apiUrl = "/v1/themeReview/register"
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiUrl)")!
    let requestURL = url
    
    var request = URLRequest(url: requestURL)
    
    request.httpMethod = HTTPMethod.post.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("\(DataHelperTool.token ?? "")", forHTTPHeaderField: "Authorization")
    
    request.httpBody = try! JSONSerialization.data(withJSONObject: ["themeId": themeDetailData.id,
                                                                    "playDate": playDate ?? "",
                                                                    "grade": rating,
                                                                    "level": selectedDifficulty.rawValue,
                                                                    "success": selectedSuccessDiff.rawValue,
                                                                    "extraTime": restTime ,
                                                                    "userHint": selectedHintCount,
                                                                    "content": contentTextView.text ?? "",
                                                                    "isGrade": isRate], options: .prettyPrinted)
    
    AF.request(request).responseJSON { [self] (response) in
      switch response.result {
      case .success(let value):
        let decoder = JSONDecoder()
        let json = JSON(value)
        let jsonData = try? json.rawData()
        
        print("\(apiUrl) responseJson: \(json)")
        
        if let data = jsonData, let value = try? decoder.decode(DefaultResponse.self, from: data) {
          if value.statusCode == 200 {
            self.callOkActionMSGDialog(message: "등록되었습니다.") {
              self.backPress()
            }
          } else {
            self.callMSGDialog(message: value.message)
            self.dismissHUD()
          }
        }
        break
      case .failure:
        print("\(apiUrl) error: \(response.error!)")
        self.dismissHUD()
        break
      }
    }
  }
  func Reregist() {
    self.showHUD()
    let apiUrl = "/v1/themeReview/update"
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiUrl)")!
    let requestURL = url
      .appending("id", value: "\(reviewData?.id ?? 0)")
    
    var request = URLRequest(url: requestURL)
    
    request.httpMethod = HTTPMethod.put.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("\(DataHelperTool.token ?? "")", forHTTPHeaderField: "Authorization")
    
    request.httpBody = try! JSONSerialization.data(withJSONObject: ["playDate": playDate ?? "",
                                                                    "grade": rating,
                                                                    "level": selectedDifficulty.rawValue,
                                                                    "success": selectedSuccessDiff.rawValue,
                                                                    "extraTime": restTime ,
                                                                    "userHint": selectedHintCount ,
                                                                    "content": contentTextView.text ?? "",
                                                                    "isGrade": isRate], options: .prettyPrinted)
    
    AF.request(request).responseJSON { [self] (response) in
      switch response.result {
      case .success(let value):
        let decoder = JSONDecoder()
        let json = JSON(value)
        let jsonData = try? json.rawData()
        
        print("\(apiUrl) responseJson: \(json)")
        
        if let data = jsonData, let value = try? decoder.decode(DefaultResponse.self, from: data) {
          if value.statusCode == 200 {
            self.callOkActionMSGDialog(message: "수정되었습니다.") {
              self.backPress()
            }
          } else {
            self.callMSGDialog(message: value.message)
            self.dismissHUD()
          }
        }
        break
      case .failure:
        print("\(apiUrl) error: \(response.error!)")
        self.dismissHUD()
        break
      }
    }
  }
  @IBAction func noscore(_ sender: UIButton){
    if(!isRate){
      notRateButton.setTitleColor(colorFromRGB(0xaaaaaa), for: .normal)
      rating = 0.5
      ratingView.rating = rating
      ratingView.didFinishTouchingCosmos = { rating in
        self.rating = rating
      }
      ratingView.didTouchCosmos = { rating in
        self.rating = rating
      }
      ratingView.settings.updateOnTouch = true
      isRate = true
    }else{
      rating = 0
      notRateButton.setTitleColor(colorFromRGB(0xffa200), for: .normal)
      ratingView.rating = 0
      ratingView.didFinishTouchingCosmos = { rating in
        self.rating = 0
      }
      ratingView.didTouchCosmos = { rating in
        self.rating = 0
      }
      ratingView.settings.updateOnTouch = false
      isRate = false
    }
    notRateButton.backgroundColor = !isRate ? colorFromRGB(0xffefbc) : colorFromRGB(0xffffff)
  }
  @IBAction func tapSelectDate(_ sender: UIButton) {
    moveToSelectDate()
  }
  
  @IBAction func tapSelectTime(_ sender: UIButton) {
    moveToCustomTimePicker()
  }
  
  @IBAction func tapRegist(_ sender: UIButton) {
    if contentTextView.text == contentTextViewPlaceHolder || contentTextView.text.isEmpty {
      callMSGDialog(message: "후기를 입력해 주세요.")
      return
    }
    if(reviewData != nil){
      Reregist()
    }else{
      regist()
    }
  }
  
}

extension RegistThemeReviewVC: SelectCalendarDateDelegate {
  func setDateString(dateString: String) {
    print("\(dateString)!!!")
    playDateLabel.text = dateString
    playDate = dateString
  }
}

extension RegistThemeReviewVC: CustomTimePickerViewDelegate {
  func selectTimeString(timeString: String, formmatString: String) {
    restTimeLabel.text = timeString
    restTime = formmatString
  }
}

extension RegistThemeReviewVC: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    textViewSetupView()
    
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    if self.contentTextView.text == "" {
      textViewSetupView()
    }
    
  }
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if text == "\n" {
      //                self.inquiryContentTextView.resignFirstResponder()
    }
    return true
  }
}

// selected Text Color ffa200 // selected BackgroundColor ffefbc
// not selected Text Color AAAAAA // not selected BackgroundColor white , border color EDEDED

extension RegistThemeReviewVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView == difficultyCollectionView {
      return difficultyList.count
    } else if collectionView == successCollectionView {
      return successDiff.count
    } else {
      return hintCount.count
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if collectionView == difficultyCollectionView {
      let cell = difficultyCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
      
      guard let titleLabel = cell.viewWithTag(2) as? UILabel else {
        return cell
      }
      
      let diff = difficultyList[indexPath.row].rawValue
      let isSame = difficultyList[indexPath.row] == selectedDifficulty
      
      titleLabel.text = diff == "매우쉬움" ? "매우 쉬움" : (diff == "매우어려움" ? "매우 어려움" : diff)
      
      titleLabel.layer.cornerRadius = 5
      titleLabel.layer.masksToBounds = true
      titleLabel.textColor = isSame ? colorFromRGB(0xffa200) : colorFromRGB(0xaaaaaa)
      titleLabel.backgroundColor = isSame ? colorFromRGB(0xffefbc) : colorFromRGB(0xffffff)
      titleLabel.layer.borderWidth = isSame ? 0 : 1
      titleLabel.layer.borderColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1.0).cgColor
      
      return cell
    } else if collectionView == successCollectionView {
      let cell = successCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
      
      guard let titleLabel = cell.viewWithTag(1) as? UILabel else {
        return cell
      }
      
      let diff = successDiff[indexPath.row].rawValue
      let isSame = successDiff[indexPath.row] == selectedSuccessDiff
      
      titleLabel.text = diff
      
      titleLabel.layer.cornerRadius = 5
      titleLabel.layer.masksToBounds = true
      titleLabel.textColor = isSame ? colorFromRGB(0xffa200) : colorFromRGB(0xaaaaaa)
      titleLabel.backgroundColor = isSame ? colorFromRGB(0xffefbc) : colorFromRGB(0xffffff)
      titleLabel.layer.borderWidth = isSame ? 0 : 1
      titleLabel.layer.borderColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1.0).cgColor
      
      return cell
    } else {
      let cell = hintCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
      
      guard let titleLabel = cell.viewWithTag(1) as? UILabel else {
        return cell
      }
      
      let diff = hintCount[indexPath.row] == 5 ? "5개 이상" : "\(hintCount[indexPath.row])개"
      let isSame = hintCount[indexPath.row] == selectedHintCount
      
      titleLabel.text = diff
      
      titleLabel.layer.cornerRadius = 5
      titleLabel.layer.masksToBounds = true
      titleLabel.textColor = isSame ? colorFromRGB(0xffa200) : colorFromRGB(0xaaaaaa)
      titleLabel.backgroundColor = isSame ? colorFromRGB(0xffefbc) : colorFromRGB(0xffffff)
      titleLabel.layer.borderWidth = isSame ? 0 : 1
      titleLabel.layer.borderColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1.0).cgColor
      
      return cell
    }
    
  }
  //MARK: - didSelectItemAt
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if collectionView == difficultyCollectionView {
      selectedDifficulty = difficultyList[indexPath.row]
      difficultyCollectionView.reloadData()
      
    } else if collectionView == successCollectionView {
      selectedSuccessDiff = successDiff[indexPath.row]
      successCollectionView.reloadData()
    } else {
      selectedHintCount = hintCount[indexPath.row]
      hintCollectionView.reloadData()
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    10
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    10
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if collectionView == difficultyCollectionView {
      let diff = difficultyList[indexPath.row].rawValue
      let text = diff == "매우쉬움" ? "매우 쉬움" : (diff == "매우어려움" ? "매우 어려움" : diff)
      let width = textWidth(text: text, font: UIFont.systemFont(ofSize: 13, weight: .medium))
      return CGSize(width: width + 24, height: 25)
    } else if collectionView == successCollectionView {
      let dict = successDiff[indexPath.row]
      let text = dict.rawValue
      let width = textWidth(text: text, font: UIFont.systemFont(ofSize: 13, weight: .medium))
      return CGSize(width: width + 24, height: 25)
    } else {
      let text = hintCount[indexPath.row] == 5 ? "5개 이상" : "\(hintCount[indexPath.row])개"
      let width = textWidth(text: text, font: UIFont.systemFont(ofSize: 13, weight: .medium))
      return CGSize(width: width + 24, height: 25)
    }
  }
  
}
