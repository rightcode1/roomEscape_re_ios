//
//  RegistCommunityBoardViewController.swift
//  room_escape
//
//  Created by hoonKim on 2021/06/20.
//  Copyright © 2021 park. All rights reserved.
//

import UIKit
import RxSwift
import RxGesture
import RxCocoa
import DropDown
import Alamofire
import SwiftyJSON



class RegistCommunityBoardViewController: BaseViewController {
  @IBOutlet var collectionView: UICollectionView!
  @IBOutlet var collectionViewHeight: NSLayoutConstraint!
  @IBOutlet var themeNameView: UIView!
  @IBOutlet var themeNameLabel: UILabel!
  
  @IBOutlet var themeAddButton: UIView!
  
  @IBOutlet var titleView: UIView!
  @IBOutlet var categoryView: UIView!
  
  @IBOutlet var titleTextField: UITextField!
  @IBOutlet var contentTextView: UITextView!
  
  @IBOutlet var exchangButton: UIView!
  @IBOutlet var getChildernButton: UIView!
  @IBOutlet var freeBoardButton: UIView!
  @IBOutlet var boardImageButton: UIView!
  @IBOutlet var infoRoomButton: UIView!
  
  @IBOutlet var exchangLabel: UILabel!
  @IBOutlet var getChildernLabel: UILabel!
  @IBOutlet var freeBoardLabel: UILabel!
  @IBOutlet var boardImageLabel: UILabel!
  @IBOutlet var infoRoomLabel: UILabel!
  
  @IBOutlet var category1Button: UIView!
  @IBOutlet var category2Button: UIView!
  @IBOutlet var category3Button: UIView!
  @IBOutlet var category4Button: UIView!
  
  @IBOutlet var category1Label: UILabel!
  @IBOutlet var category2Label: UILabel!
  @IBOutlet var category3Label: UILabel!
  @IBOutlet var category4Label: UILabel!
  
  
  var imagePicker = UIImagePickerController()
  var imageList:[(UIImage, Int)]  = [(UIImage(named: "iconPlus")!, -1)]
  var companyName: String?
  var themeName: String?{
    didSet{
      if themeName != nil{
        themeNameLabel.text = themeName
      }else{
        themeNameLabel.text = "테마를 선택해주세요."
      }
    }
  }
  
  var themeId: Int?
  var boardId: Int?
  var boardCategory: BoardCategory? = nil{
    didSet{
      setNotSelectButtonColor(category1Button, category1Label)
      setNotSelectButtonColor(category2Button, category2Label)
      setNotSelectButtonColor(category3Button, category3Label)
      setNotSelectButtonColor(category4Button, category4Label)
      switch boardCategory {
      case .공지:
        break
      case .정보:
        setSelectButtonColor(category1Button, category1Label)
      case .소식:
        setSelectButtonColor(category2Button, category2Label)
      case .이벤트:
        setSelectButtonColor(category3Button, category3Label)
      case .후기:
        setSelectButtonColor(category4Button, category4Label)
      case .모집중:
        setSelectButtonColor(category1Button, category1Label)
      case .모집완료:
        setSelectButtonColor(category2Button, category2Label)
      case .진행:
        setSelectButtonColor(category1Button, category1Label)
      case .마감:
        setSelectButtonColor(category2Button, category2Label)
      case .최신순:
        setSelectButtonColor(category1Button, category1Label)
      case .추천순:
        setSelectButtonColor(category2Button, category2Label)
      case nil:
        break
      }
    }
  }
  var boardDiff: BoardDiff? = nil{
    didSet{
      boardCategory = nil
      setNotSelectButtonColor(exchangButton, exchangLabel)
      setNotSelectButtonColor(getChildernButton, getChildernLabel)
      setNotSelectButtonColor(freeBoardButton, freeBoardLabel)
      setNotSelectButtonColor(boardImageButton, boardImageLabel)
      setNotSelectButtonColor(infoRoomButton, infoRoomLabel)
      switch boardDiff{
      case .양도교환:
        titleView.isHidden = false
        themeNameView.isHidden = false
        categoryView.isHidden = false
        category1Label.text = "진행"
        category2Label.text = "마감"
        category3Button.isHidden = true
        category4Button.isHidden = true
        setSelectButtonColor(exchangButton, exchangLabel)
      case .일행구하기:
        titleView.isHidden = false
        themeNameView.isHidden = false
        categoryView.isHidden = false
        category1Label.text = "모집중"
        category2Label.text = "모집완료"
        category3Button.isHidden = true
        category4Button.isHidden = true
        setSelectButtonColor(getChildernButton, getChildernLabel)
      case .자유게시판:
        titleView.isHidden = false
        themeNameView.isHidden = true
        categoryView.isHidden = true
        setSelectButtonColor(freeBoardButton, freeBoardLabel)
      case .보드판갤러리:
        titleView.isHidden = true
        themeNameView.isHidden = false
        categoryView.isHidden = true
        setSelectButtonColor(boardImageButton, boardImageLabel)
      case .방탈출정보:
        titleView.isHidden = false
        themeNameView.isHidden = true
        categoryView.isHidden = false
        category1Label.text = "정보"
        category2Label.text = "소식"
        category3Button.isHidden = false
        category4Button.isHidden = false
        setSelectButtonColor(infoRoomButton, infoRoomLabel)
      default:
        break
      }
    }
  }
  
  let contentTextViewPlaceHolder = "게시판 글을 입력해주세요."
  
  override func viewDidLoad() {
    super.viewDidLoad()
    imagePicker.delegate = self
    contentTextView.delegate = self
    bindInput()
    if boardId != nil{
      boardDetail()
    }
  }
  override func viewWillAppear(_ animated: Bool) {
      navigationController?.navigationBar.isHidden = false
  }
  
  // 텍스트 뷰에 텍스트홀더 넣어주는법
  func textViewSetupView() {
    if contentTextView.text == contentTextViewPlaceHolder {
      contentTextView.text = ""
      contentTextView.textColor = .black
    } else if contentTextView.text.isEmpty {
      contentTextView.text = contentTextViewPlaceHolder
      contentTextView.textColor = UIColor.lightGray
    }
  }
  func setSelectButtonColor(_ button: UIView,_ textView : UILabel) {
    button.backgroundColor = UIColor(red: 255, green: 239, blue: 188)
    button.borderColor = .clear
    textView.textColor = UIColor(red: 255, green: 162, blue: 0)
  }
  
  func setNotSelectButtonColor(_ button: UIView,_ textView: UILabel) {
    button.backgroundColor = .white
    button.borderColor = #colorLiteral(red: 0.9294117093, green: 0.9294117093, blue: 0.9294117093, alpha: 1)
    textView.textColor = .lightGray
  }
  
  func bindInput() {
    exchangButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        if self?.boardId != nil{
          return
        }
        self?.boardDiff = .양도교환
      })
      .disposed(by: disposeBag)
    
    getChildernButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        if self?.boardId != nil{
          return
        }
        self?.boardDiff = .일행구하기
      })
      .disposed(by: disposeBag)
    
    freeBoardButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        if self?.boardId != nil{
          return
        }
        self?.boardDiff = .자유게시판
      })
      .disposed(by: disposeBag)
    
    boardImageButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        if self?.boardId != nil{
          return
        }
        self?.boardDiff = .보드판갤러리
      })
      .disposed(by: disposeBag)
    infoRoomButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        if self?.boardId != nil{
          return
        }
        self?.boardDiff = .방탈출정보
      })
      .disposed(by: disposeBag)
    
    category1Button.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        if let category = BoardCategory(rawValue: self?.category1Label.text ?? "") {
          self?.boardCategory = category
        } else {
          self?.boardCategory = nil
        }
      })
      .disposed(by: disposeBag)
    
    category2Button.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        if let category = BoardCategory(rawValue: self?.category2Label.text ?? "") {
          self?.boardCategory = category
        } else {
          self?.boardCategory = nil
        }
      })
      .disposed(by: disposeBag)
    
    category3Button.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        if let category = BoardCategory(rawValue: self?.category3Label.text ?? "") {
          self?.boardCategory = category
        } else {
          self?.boardCategory = nil
        }
      })
      .disposed(by: disposeBag)
    
    category4Button.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        if let category = BoardCategory(rawValue: self?.category4Label.text ?? "") {
          self?.boardCategory = category
        } else {
          self?.boardCategory = nil
        }
      })
      .disposed(by: disposeBag)
    
    
    themeAddButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        let vc = UIStoryboard.init(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "CommunityThemeListViewController") as! CommunityThemeListViewController
        vc.delegate = self
        self?.navigationController?.pushViewController(vc, animated: true)
        
      })
      .disposed(by: disposeBag)
    
    
  }
  func regist() {
    self.showHUD()
    let apiUrl = "/v1/boards/register"
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiUrl)")!
    var request = URLRequest(url: url)
    request.httpMethod = HTTPMethod.post.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("\(DataHelperTool.token ?? "")", forHTTPHeaderField: "Authorization")
    
    request.httpBody = try! JSONSerialization.data(withJSONObject: [
      "diff": boardDiff?.rawValue,
      "category": (boardDiff == .일행구하기 || boardDiff == .양도교환 || boardDiff == .방탈출정보) ? boardCategory?.rawValue : nil,
      "themeId": (boardDiff == .양도교환 || boardDiff == .일행구하기) ? themeId ?? 0 : nil,
      "company_name": boardDiff == .보드판갤러리 ? companyName : nil,
      "theme_name": boardDiff == .보드판갤러리 ? themeName : nil,
      "title": boardDiff == .보드판갤러리 ? nil : titleTextField.text!,
      "content": contentTextView.text! ], options: .prettyPrinted)
    AF.request(request).responseJSON { [self] (response) in
      switch response.result {
      case .success(let value):
        let decoder = JSONDecoder()
        let json = JSON(value)
        let jsonData = try? json.rawData()
        
        print("\(apiUrl) responseJson: \(json)")
        
        if let data = jsonData, let value = try? decoder.decode(DefaultIDResponse.self, from: data) {
          if value.statusCode >= 202 {
            self.dismissHUD()
            self.callMSGDialog(message: value.message)
          }else {
            self.registDetailImages(boardId: value.data?.id ?? 0)
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
  
  func openAlbum() {
    if UI_USER_INTERFACE_IDIOM() == .pad {
      self.imagePicker.sourceType = .photoLibrary
      self.imagePicker.mediaTypes = ["public.image"]
      self.present(self.imagePicker, animated: true, completion: nil)
    } else {
      let alert =  UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
      
      let library =  UIAlertAction(title: "앨범", style: .default) { (action) in
        self.imagePicker.sourceType = .photoLibrary
        self.imagePicker.mediaTypes = ["public.image"]
        self.present(self.imagePicker, animated: true, completion: nil)
      }
      alert.addAction(library)
      
      let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
      alert.addAction(cancel)
      present(alert, animated: true, completion: nil)
    }
  }
  
//  func initImageArray() {
//    DispatchQueue.global().sync {
//      if self.imageList.count > 0 {
//        if self.imageList.count != 6 {
//          for _ in 0 ..< self.imageList.count {
//            self.imageList.append((#imageLiteral(resourceName: "iconPlus"), 0))
//          }
//        }
//      }
//    }
//    print("imageList count 2: \(self.imageList.count)")
//    DispatchQueue.main.async {
//      self.collectionView.reloadData()
//    }
//  }
  
  func appendImageArray(list: [BoardImage]) {
    
    DispatchQueue.global().sync {
      print("detailImages : \(list)")
      if list.count > 0 {
        for i in 0..<list.count {
          print("I : \(i) ???")
          let imageName = "https://d35jysenqmci34.cloudfront.net/\(list[i].name)"
          let id = list[i].id
          do {
            if let data = try? Data(contentsOf: URL(string: imageName)!) {
              let imageData = UIImage(data: data)
              let image = imageData!.resizeToWidth(newWidth: self.view.frame.width)
              self.imageList.append(((image, id)))
              print("imageList Append : \(self.imageList)")
//              if i == (list.count - 1) {
//                self.initImageArray()
//              }
            }
            
          }
        }
      }
      DispatchQueue.main.async {
        self.collectionView.reloadData()
      }
      print("imageList 1: \(self.imageList)")
      print("imageList count 1: \(self.imageList.count)")
    }
  }
  
  func initUIWithBoardDetailData(_ data: BoardDetail) {
    boardDiff = data.diff
    if (boardDiff == .자유게시판 || boardDiff == .방탈출정보) {
      categoryView.isHidden = true
    }
    if let category = BoardCategory(rawValue: data.category!) {
      self.boardCategory = category
    } else {
      self.boardCategory = nil
    }
    titleView.isHidden = data.diff == .보드판갤러리
    titleTextField.text = data.title
    
    contentTextView.text = data.content
    contentTextView.textColor = .black
    
    themeNameView.isHidden = !(data.diff == .보드판갤러리 || data.diff == .양도교환 || data.diff == .일행구하기)
    
    themeId = data.theme != nil ? data.theme?.id : nil
    themeName = data.theme != nil ? data.theme?.title : nil
    companyName = data.theme != nil ? data.theme?.companyName : nil
    
    appendImageArray(list: data.boardImages)
    collectionView.reloadData()
    
    self.dismissHUD()
  }
  
  func finishRegist() {
    self.dismissHUD()
    self.callOkActionMSGDialog(message: boardId == nil ? "등록이 완료되었습니다." : "수정이 완료되었습니다.") {
      boardUpdateId = 0
      self.backPress()
    }
  }
  
  func boardDetail() {
    self.showHUD()
    ApiService.request(router: BoardApi.boardDetail(id: boardId ?? 0), success: { (response: ApiResponse<BoardDetailResponse>) in
      guard let value = response.value else {
        return
      }
      if value.statusCode == 200 {
        self.initUIWithBoardDetailData(value.data)
      } else {
        self.dismissHUD()
      }
    }) { (error) in
      self.dismissHUD()
    }
  }
  
  func removeImage(id: Int) {
    ApiService.request(router: BoardApi.removeBoardImage(id: id), success: { (response: ApiResponse<DefaultResponse>) in
      guard let value = response.value else {
        return
      }
      print(value)
    }) { (error) in
    }
  }
  
  func registDetailImages(boardId: Int) {
    let uploadGroup = DispatchGroup()
    uploadGroup.enter()
    print(self.imageList)
    let uploadImageList = self.imageList.filter { $0.0 != #imageLiteral(resourceName: "iconPlus") && $0.1 == 0 }
    
    print(uploadImageList)
    if uploadImageList.count > 0 {
      print("!!1")
      ApiService.upload(router: BoardApi.registBoardImage(boardId: boardId), multiPartFormHanler: { multipartFormData in
        DispatchQueue.global().sync {
          for (index, image) in uploadImageList.enumerated() {
            let image = image.0.jpegData(compressionQuality: 0.1)!
            multipartFormData.append(image, withName: "image", fileName:  "\(boardId)" + "_board" + String(index) + ".jpg", mimeType: "image/jpeg")
          }
        }
      }, success: { (response: ApiResponse<DefaultResponse>) in
        print("imageListReponse : \(response)")
        uploadGroup.leave()
      }, failure: { (error) in
        print("imageListError : \(String(describing: error))")
      })
      
      uploadGroup.notify(queue: .main) {
        self.finishRegist()
      }
    } else {
      print("!!2")
      self.finishRegist()
    }
  }
  
  func update() {
    self.showHUD()
    let apiUrl = "/v1/boards/update"
    let url = URL(string: "\(ApiEnvironment.baseUrl)\(apiUrl)")!
    let requestURL = url.appending("id",value: "\(boardId!)")
    var request = URLRequest(url: requestURL)
    request.httpMethod = HTTPMethod.put.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("\(DataHelperTool.token ?? "")", forHTTPHeaderField: "Authorization")
    
    request.httpBody = try! JSONSerialization.data(withJSONObject: [
      "diff": boardDiff?.rawValue,
      "category": (boardDiff == .일행구하기 || boardDiff == .양도교환 || boardDiff == .방탈출정보) ? boardCategory?.rawValue : nil,
      "themeId": (boardDiff == .양도교환 || boardDiff == .일행구하기) ? themeId ?? 0 : nil,
      "company_name": boardDiff == .보드판갤러리 ? companyName : nil,
      "theme_name": boardDiff == .보드판갤러리 ? themeName : nil,
      "title": boardDiff == .보드판갤러리 ? nil : titleTextField.text!,
      "content": contentTextView.text! ], options: .prettyPrinted)
    AF.request(request).responseJSON { [self] (response) in
      switch response.result {
      case .success(let value):
        let decoder = JSONDecoder()
        let json = JSON(value)
        let jsonData = try? json.rawData()
        
        print("\(apiUrl) responseJson: \(json)")
        
        if let data = jsonData, let value = try? decoder.decode(DefaultIDResponse.self, from: data) {
          if value.statusCode >= 202 {
            self.dismissHUD()
            self.callMSGDialog(message: value.message)
          }else {
            self.registDetailImages(boardId: value.data?.id ?? 0)
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
  
  @objc
  func deleteImageTapped(_ sender: UIButton) {
    if let index = Int(sender.accessibilityHint!) {
      if imageList[index].1 > 0 {
        removeImage(id: imageList[index].1)
      }
      imageList.remove(at: index)
      collectionView.reloadData()
    }
  }
  
  @IBAction func tapSave(_ sender: UIButton) {
    if boardDiff == nil{
      callMSGDialog(message: "게시판을 선택해주세요.")
      return
    }
    if boardDiff == .양도교환 || boardDiff == .일행구하기 || boardDiff == .보드판갤러리{
      if themeId == nil {
        callMSGDialog(message: "테마를 선택해주세요.")
        return
      }
    }
    
    if boardDiff != .보드판갤러리 && titleTextField.text!.isEmpty {
      callMSGDialog(message: "제목을 입력해주세요.")
      return
    }
    
    if boardDiff == .양도교환 || boardDiff == .일행구하기 || boardDiff == .방탈출정보{
      if boardCategory == nil {
        callMSGDialog(message: "정렬을 선택해주세요.")
        return
      }
    }
    
    if contentTextView.text == contentTextViewPlaceHolder || contentTextView.text!.isEmpty {
      callMSGDialog(message: "게시판 글을 입력해주세요.")
      return
    }
    
    
    let isExistUploadImage = imageList.filter{ $0.0 != #imageLiteral(resourceName: "iconPlus") }.count > 0
    
    if boardDiff == .보드판갤러리 && !isExistUploadImage {
      callMSGDialog(message: "사진을 한장이상 선택해주세요.")
      return
    }
    
    
    if boardId != nil {
      update()
    } else {
      regist()
    }
  }
  
}


extension RegistCommunityBoardViewController: UITextViewDelegate {
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

// MARK: - imagePicker
extension RegistCommunityBoardViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
      imageList.append((image , 0))
      
      collectionView.reloadData()
      picker.dismiss(animated: true, completion: nil)
    }
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
}

// MARK: - CollectionView
extension RegistCommunityBoardViewController: UICollectionViewDelegate, UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout{
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 70, height: 70)
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.imageList.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    guard let imageView = cell.viewWithTag(1) as? UIImageView,
          let deleteButton = cell.viewWithTag(2) as? UIButton else { return cell }
    imageView.image = imageList[indexPath.row].0
    imageView.layer.cornerRadius = 12
    if imageList[indexPath.row].0 == #imageLiteral(resourceName: "iconPlus") {
      deleteButton.isHidden = true
    } else {
      deleteButton.isHidden = false
    }
    deleteButton.accessibilityHint = String(indexPath.row)
    deleteButton.addTarget(self, action: #selector(deleteImageTapped(_:)), for: .touchUpInside)
    
    return cell
    
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if imageList.count > 6{
      callOkActionMSGDialog(message: "사진은 최대 6장까지 첨부 가능합니다.") {
      }
      return
    }
    openAlbum()
  }
}
extension RegistCommunityBoardViewController: TapTheme{
  func tapDetail(themeId: Int, themeName: String, themeCompany: String) {
    self.themeId = themeId
    self.themeName = themeName
    self.companyName = themeCompany
  }
}
