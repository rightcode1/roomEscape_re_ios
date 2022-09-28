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

class RegistCommunityBoardViewController: BaseViewController {
  @IBOutlet var collectionView: UICollectionView!
  @IBOutlet var collectionViewHeight: NSLayoutConstraint!
  
  @IBOutlet var modifyInfoView: UIView!
  
  @IBOutlet var galleryStackView: UIStackView!
  @IBOutlet var cafeNameLabel: UILabel!
  @IBOutlet var themeNameLabel: UILabel!
  
  @IBOutlet var titleStackView: UIStackView!
  @IBOutlet var cruitImageView: UIImageView!
  @IBOutlet var titleLabel: UILabel!
  
  @IBOutlet var gradeImageView: UIImageView!
  @IBOutlet var nameLabel: UILabel!
  
  @IBOutlet var dateLabel: UILabel!
  @IBOutlet var reviewCountLabel: UILabel!
  
  @IBOutlet var cafeNameView: UIView!
  @IBOutlet var themeNameView: UIView!
  
  @IBOutlet var titleView: UIView!
  
  @IBOutlet var cafeNameTextField: UITextField!
  @IBOutlet var themeNameTextField: UITextField!
  
  @IBOutlet var categoryView: UIView!
  @IBOutlet var categoryDropDownTextField: UITextField!
  @IBOutlet var categoryDropDownView: UIView!
  
  
  @IBOutlet var titleTextField: UITextField!
  @IBOutlet var contentTextView: UITextView!
  
  var imagePicker = UIImagePickerController()
  
  let categoryDropDown = DropDown()
  
  var boardId: Int?
  
  var boardDiff: BoardDiff = .자유게시판
  
  var boardImageList: [BoardImage] = []
  var imageList:[(UIImage, Int)]  = []
  
  var isModify: Bool = false
  
  let recruitCategroyArray: [String] = ["모집중", "모집완료"]
  
  let infoCategoryArray: [String] = ["정보", "소식", "이벤트", "후기"]
  
  let contentTextViewPlaceHolder = "게시판 글을 입력해주세요."
  
  override func viewDidLoad() {
    super.viewDidLoad()
    imagePicker.delegate = self
    contentTextView.delegate = self
    setDropDown()
    bindInput()
    
    initViews()
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
  
  func setDropDown() {
    categoryDropDown.anchorView = categoryDropDownView
    categoryDropDown.dataSource = boardDiff == .일행구하기 ? recruitCategroyArray : infoCategoryArray
    categoryDropDown.backgroundColor = .white
    categoryDropDown.direction = .bottom
    categoryDropDown.selectionAction = { [weak self] (index: Int, item: String) in
      guard let self = self else { return }
      self.categoryDropDownTextField.text = item
    }
  }
  
  func bindInput() {
    categoryDropDownView.rx.gesture(.tap()).when(.recognized).subscribe(onNext: {  [weak self] _ in
      guard let self = self else { return }
      self.categoryDropDown.show()
    }).disposed(by: disposeBag)
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
  
  func initViews() {
    navigationItem.title = boardDiff.rawValue
    galleryStackView.isHidden = boardDiff != .보드판갤러리
    titleStackView.isHidden = boardDiff == .보드판갤러리
    
    cafeNameView.isHidden = boardDiff != .보드판갤러리
    themeNameView.isHidden = boardDiff != .보드판갤러리
    titleView.isHidden = boardDiff == .보드판갤러리
    
    if boardId != nil {
      categoryView.isHidden = boardDiff != .일행구하기
      boardDetail()
    } else {
      if (boardDiff == .일행구하기 || boardDiff == .방탈출정보) {
        categoryView.isHidden = false
      }
      for _ in 0..<(6 - self.imageList.count) {
        self.imageList.append((#imageLiteral(resourceName: "iconPlus"), 0))
      }
      
      collectionView.reloadData()
    }
    
    categoryDropDown.reloadAllComponents()
  }
  
  func initImageArray() {
    DispatchQueue.global().sync {
      if self.imageList.count > 0 {
        if self.imageList.count != 6 {
          for _ in 0..<(6 - self.imageList.count) {
            self.imageList.append((#imageLiteral(resourceName: "iconPlus"), 0))
          }
        }
      }
    }
    print("imageList count 2: \(self.imageList.count)")
    DispatchQueue.main.async {
      self.collectionView.reloadData()
    }
  }
  
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
              if i == (list.count - 1) {
                self.initImageArray()
              }
            }
            
          }
        }
      } else {
        for _ in 0..<6 {
          self.imageList.append((#imageLiteral(resourceName: "iconPlus"), 0))
        }
        DispatchQueue.main.async {
          self.collectionView.reloadData()
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
    cafeNameView.isHidden = data.diff != .보드판갤러리
    themeNameView.isHidden = data.diff != .보드판갤러리
    titleView.isHidden = data.diff == .보드판갤러리
    
    if (boardDiff == .일행구하기 || boardDiff == .방탈출정보) {
      categoryView.isHidden = false
    }
    
    modifyInfoView.isHidden = true
    
    boardDiff = data.diff
    
    boardImageList = data.boardImages
    appendImageArray(list: data.boardImages)
    
    cruitImageView.isHidden = data.category == nil
    cruitImageView.image = data.category == "모집중" ? #imageLiteral(resourceName: "recruitImage") : #imageLiteral(resourceName: "finishRecruitImage")
    
    switch data.grade {
      case "0":
        gradeImageView.image = #imageLiteral(resourceName: "user_medal_1_10")
      case "1":
        gradeImageView.image = #imageLiteral(resourceName: "user_medal_11_50")
      case "2":
        gradeImageView.image = #imageLiteral(resourceName: "user_medal_51_100")
      case "3":
        gradeImageView.image = #imageLiteral(resourceName: "user_medal_101_200")
      case "4":
        gradeImageView.image = #imageLiteral(resourceName: "user_medal_201_300")
      case "5":
        gradeImageView.image = #imageLiteral(resourceName: "user_medal_301_500")
      case "6":
        gradeImageView.image = #imageLiteral(resourceName: "user_medal_501_1000")
      case "7":
        gradeImageView.image = #imageLiteral(resourceName: "user_medal_1000")
      default:
        gradeImageView.image = #imageLiteral(resourceName: "user_medal_1_10")
    }
    
    cafeNameLabel.text = "카페명 : \(data.company_name ?? "")"
    cafeNameTextField.text = data.company_name ?? ""
    
    themeNameLabel.text = "테마명 : \(data.theme_name ?? "")"
    themeNameTextField.text = data.theme_name ?? ""
    
    titleLabel.text = data.title
    titleTextField.text = data.title
    
    contentTextView.text = data.content
    
    categoryDropDownTextField.text = data.category
    
    nameLabel.text = data.nickname
    dateLabel.text = data.createdAt
    reviewCountLabel.text = "\(data.commentCount)"
    
    
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
    let uploadImageList = self.imageList.filter { $0.0 != #imageLiteral(resourceName: "iconPlus") && $0.1 == 0 }
    
    if uploadImageList.count > 0 {
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
      self.finishRegist()
    }
  }
  
  func registBoard() {
    self.showHUD()
    boardUpdateId = boardId ?? 0
    let param = RegistBoardRequest(
      user_pk: "\(DataHelperTool.userAppId ?? 0)",
      nickname: DataHelperTool.userNickname ?? "",
      grade: "1",
      title: boardDiff == .보드판갤러리 ? "title" : titleTextField.text!,
      content: contentTextView.text!,
      diff: boardDiff,
      company_name: boardDiff == .보드판갤러리 ? cafeNameTextField.text! : nil,
      theme_name: boardDiff == .보드판갤러리 ? themeNameTextField.text! : nil,
      category: (boardDiff == .일행구하기 || boardDiff == .방탈출정보) ? categoryDropDownTextField.text! : nil
    )
    ApiService.request(router: BoardApi.registBoard(param: param), success: { (response: ApiResponse<DefaultIDResponse>) in
      guard let value = response.value else {
        return
      }
      
      if value.statusCode >= 202 {
        self.dismissHUD()
        self.callMSGDialog(message: value.message)
      }else {
        self.registDetailImages(boardId: value.data?.id ?? 0)
      }
      
    }) { (error) in
      self.dismissHUD()
      self.callMSGDialog(message: "알수없는 오류입니다. 잠시후 다시 시도해주세요.")
    }
  }
  
  func updateBoard() {
    self.showHUD()
    boardUpdateId = boardId ?? 0
    let param = ModifyBoardRequest(
      title: boardDiff == .보드판갤러리 ? "title" : titleTextField.text!,
      company_name: boardDiff == .보드판갤러리 ? cafeNameTextField.text! : nil,
      theme_name: boardDiff == .보드판갤러리 ? themeNameTextField.text! : nil,
      content: contentTextView.text!,
      category: (boardDiff == .일행구하기 || boardDiff == .방탈출정보) ? categoryDropDownTextField.text! : nil 
    )
    ApiService.request(router: BoardApi.modifyBoard(param: param), success: { (response: ApiResponse<DefaultIDResponse>) in
      guard let value = response.value else {
        return
      }
      
      if value.statusCode >= 202 {
        self.dismissHUD()
        self.callMSGDialog(message: value.message)
      }else {
        self.registDetailImages(boardId: boardUpdateId)
      }
      
    }) { (error) in
      self.dismissHUD()
      self.callMSGDialog(message: "알수없는 오류입니다. 잠시후 다시 시도해주세요.")
    }
  }
  
  @objc
  func deleteImageTapped(_ sender: UIButton) {
    if let index = Int(sender.accessibilityHint!) {
      if imageList[index].1 > 0 {
        removeImage(id: imageList[index].1)
      }
      imageList.remove(at: index)
      imageList.append((#imageLiteral(resourceName: "iconPlus"), 0))
      collectionView.reloadData()
    }
  }
  
  @IBAction func tapSave(_ sender: UIButton) {

    if boardDiff == .보드판갤러리 {
      if cafeNameTextField.text!.isEmpty {
        callMSGDialog(message: "카페명을 입력해주세요.")
        return
      }

      if themeNameTextField.text!.isEmpty {
        callMSGDialog(message: "테마명을 입력해주세요.")
        return
      }

      let isExistUploadImage = imageList.filter{ $0.0 != #imageLiteral(resourceName: "iconPlus") }.count > 0

      if !isExistUploadImage {
        callMSGDialog(message: "사진을 한장이상 선택해주세요.")
        return
      }
    } else {
      if titleTextField.text!.isEmpty {
        callMSGDialog(message: "제목을 입력해주세요.")
        return
      }
    }

    if contentTextView.text == contentTextViewPlaceHolder || contentTextView.text!.isEmpty {
      callMSGDialog(message: "게시판 글을 입력해주세요.")
      return
    }

    if boardId != nil {
      updateBoard()
    } else {
      registBoard()
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
      imageList.removeLast()
      let insertIndex = self.imageList.filter { $0.0 != #imageLiteral(resourceName: "iconPlus") }.count
      imageList.insert((image , 0), at: (insertIndex))
      
      collectionView.reloadData()
      picker.dismiss(animated: true, completion: nil)
    }
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
}

// MARK: - CollectionView
extension RegistCommunityBoardViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return imageList.count
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
    openAlbum()
  }
}

extension RegistCommunityBoardViewController: UICollectionViewDelegateFlowLayout {
//  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//    return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
//  }
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 70, height: 70)
  }
//  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//    return 10
//
//  }
//  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//    let spanicg = ((UIScreen.main.bounds.width - 30) - 270) / 2
//    return spanicg
//  }
}
