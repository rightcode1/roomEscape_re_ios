//
//  CommunityDetailViewController.swift
//  room_escape
//
//  Created by hoonKim on 2021/06/20.
//  Copyright © 2021 park. All rights reserved.
//

import UIKit
import Kingfisher
import Cosmos

extension UIStackView {
  func removeAllArrangedSubviews() {
    arrangedSubviews.forEach {
      self.removeArrangedSubview($0)
      NSLayoutConstraint.deactivate($0.constraints)
      $0.removeFromSuperview()
    }
  }
}

class CommunityDetailViewController: BaseViewController {
  @IBOutlet var communityLabel: UILabel!
  @IBOutlet var collectionView: UICollectionView!
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var tableViewHeight: NSLayoutConstraint!
  
  @IBOutlet var titleLabel: UILabel!
  
  @IBOutlet var gradeLabel: UILabel!
  
  @IBOutlet var nameLabel: UILabel!
  
  @IBOutlet var dateLabel: UILabel!
  @IBOutlet var commentCount: UILabel!
  //  @IBOutlet var reviewCountLabel: UILabel!
  @IBOutlet var communityCategory: UIImageView!
  @IBOutlet var communityCategoryWidth: NSLayoutConstraint!
  
  @IBOutlet var contentTextView: UITextView!
  
  @IBOutlet var themeStackView: UIView!
  @IBOutlet var themeImageView: UIImageView!
  @IBOutlet var themeTitleLabel: UILabel!
  @IBOutlet var themeDiffLabel: UILabel!
  @IBOutlet var themeCompanyLabel: UILabel!
  @IBOutlet var themecompanyAverage: CosmosView!
  @IBOutlet var themecompnayAverageText: UILabel!
  @IBOutlet var themecompanyLIkeCount: UILabel!
  
  @IBOutlet var imageStackView: UIStackView!
  
  @IBOutlet var imageListView: UIView! // collectionView
  
  
  @IBOutlet var reviewTextView: UITextView!
  
  @IBOutlet weak var inputTextView: UITextView!
  
  @IBOutlet weak var registCommentButton: UIButton!
  
  @IBOutlet weak var replyView: UIView!
  @IBOutlet weak var replyLabel: UILabel!
  
  @IBOutlet var reportButton: UILabel!
  @IBOutlet var modifyButton: UILabel!
  @IBOutlet var deleteButton: UILabel!
  
  
  
  let inputTextViewPlaceHolder = "댓글을 입력해주세요."
  
  let cellIdentifier: String = "CommunityBoardCommentListCell"
  var registUserId: String = ""
  
  var boardDiff: BoardDiff = .자유게시판 {
    didSet{
      communityLabel.text = boardDiff.rawValue
    }
  }
  
  var boardId: Int?
  
  var boardCommentList: [BoardCommentList] = []
  
  var boardImageList: [BoardImage] = []
  
  var sendCommentId: Int?
  
  var sendCommentName: String?
  
  var boardThemeId: Int?
  
  var isLike: Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    registerXib()
    tableView.delegate = self
    tableView.dataSource = self
    
    inputTextView.delegate = self
    reviewTextView.delegate = self
    
    initrx()
  }
  func initrx(){
      modifyButton.rx.tapGesture().when(.recognized)
        .bind(onNext: { [weak self] _ in
          let vc = UIStoryboard.init(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "RegistCommunityBoardViewController") as! RegistCommunityBoardViewController
          vc.boardId = self?.boardId
          self?.navigationController?.pushViewController(vc, animated: true)
        })
        .disposed(by: disposeBag)
    deleteButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        self?.callYesNoMSGDialog(message: "해당 게시글을 삭제하시겠습니까?") {
          self?.removeBoard()
        }
      })
      .disposed(by: disposeBag)
    reportButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        self?.callYesNoMSGDialog(message: "게시물을 신고하시겠습니까?") {
          self?.showToast(message: "게시물 신고 완료하였습니다.")
          DataHelper<Int>.appendReportList(self?.boardId ?? 0)
          self?.backPress()
        }
      })
      .disposed(by: disposeBag)
    themeStackView.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        let vc = UIStoryboard.init(name: "Thema", bundle: nil).instantiateViewController(withIdentifier: "DetailThemaVC") as! DetailThemaVC
        vc.id = self?.boardThemeId
        self?.goViewController(vc: vc)
      })
      .disposed(by: disposeBag)
    
  }
  
  
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.navigationBar.isHidden = true
    boardDetail()
    initBoardCommentList()
  }
  
  private func registerXib() {
    let nibName = UINib(nibName: cellIdentifier, bundle: nil)
    tableView.register(nibName, forCellReuseIdentifier: cellIdentifier)
  }
  
  func textViewSetupView() {
    if inputTextView.text == inputTextViewPlaceHolder {
      inputTextView.text = ""
      inputTextView.textColor = UIColor.black
    } else if inputTextView.text.isEmpty {
      inputTextView.text = inputTextViewPlaceHolder
      inputTextView.textColor = UIColor.lightGray
    }
  }
  
  // 텍스트의 맞게 텍스트뷰 높이 설정
  func setTextViewHeight() {
    let size = CGSize(width: inputTextView.frame.width, height: .infinity)
    let estimatedSize = inputTextView.sizeThatFits(size)
    inputTextView.constraints.forEach { (constraint) in
      if constraint.firstAttribute == .height {
        constraint.constant = estimatedSize.height
      }
    }
  }
  
  func initImageStackView(images: [BoardImage]) {
    for i in 0..<(images.count) {
      KingfisherManager.shared.retrieveImage(with: URL(string: "https://d35jysenqmci34.cloudfront.net/fit-in/\(images[i].name)")!) { result in
        switch result {
        case .success(let value):
          let image = value.image.resizeToWidth(newWidth: self.view.frame.width - 30)
          
          let view = UIView(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
          
          view.translatesAutoresizingMaskIntoConstraints = false
          view.widthAnchor.constraint(equalToConstant: image.size.width).isActive = true
          view.heightAnchor.constraint(equalToConstant: image.size.height).isActive = true
          
          let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
          
          imageView.translatesAutoresizingMaskIntoConstraints = false
          imageView.widthAnchor.constraint(equalToConstant: image.size.width).isActive = true
          imageView.heightAnchor.constraint(equalToConstant: image.size.height).isActive = true
          
          imageView.contentMode = .scaleToFill
          imageView.clipsToBounds = true
          imageView.image = image
          
          view.addSubview(imageView)
          
          let showButton = UIButton(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
          
          showButton.translatesAutoresizingMaskIntoConstraints = false
          showButton.widthAnchor.constraint(equalToConstant: image.size.width).isActive = true
          showButton.heightAnchor.constraint(equalToConstant: image.size.height).isActive = true
          
          showButton.setTitle("", for: .normal)
          showButton.tag = i + 1
          //            showButton.addTarget(self, action: #selector(self.tapDetailImage(_ :)), for: .touchUpInside)
          
          view.addSubview(showButton)
          
          self.imageStackView.addArrangedSubview(view)
        case .failure:
          break
        }
      }
    }
  }
  
  func initTableViewHeightWithBoardCommentList() {
    DispatchQueue.global().sync {
      var height: CGFloat = 0
      
      let mainWidth = UIScreen.main.bounds.width
      
      for dict in boardCommentList {
        let textHeight = dict.content.height(withConstrainedWidth: mainWidth - (dict.depth == "0" ? 30 : 65), font: .systemFont(ofSize: 11))
        
        height += (textHeight + 59)
      }
      
      DispatchQueue.main.async {
        self.tableViewHeight.constant = height
      }
    }
  }
  
  func initUIWithBoardDetailData(_ data: BoardDetail) {
    boardDiff = data.diff
    registUserId = data.user_pk
    boardThemeId = data.theme?.id
    imageStackView.removeAllArrangedSubviews()
    if data.theme != nil{
      themeStackView.isHidden = false
      themeDiffLabel.text = data.theme?.category
      self.themeImageView.kf.setImage(with: URL(string: data.theme?.thumbnail ?? ""))
      self.themeTitleLabel.text = data.theme?.title
      self.themeCompanyLabel.text = data.theme?.companyName
      self.themecompanyAverage.rating = data.theme?.grade ?? 0.0
      self.themecompnayAverageText.text = "\(data.theme?.grade ?? 0) (\(data.theme?.grade ?? 0))"
      self.themecompanyLIkeCount.text = "\(data.theme?.wishCount ?? 0)"
    }else{
      themeStackView.isHidden = true
    }
    //    boardImageList = data.boardImages
    //    imageListView.isHidden = data.boardImages.count == 0
    
    if data.boardImages.count > 0 {
      initImageStackView(images: data.boardImages)
    }
    
    switch data.grade{
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
    
    commentCount.text = "\(data.commentCount)"
    
    switch data.category {
    case "공지":
      communityCategory.image = #imageLiteral(resourceName: "infoDiffIcon5")
    case "정보":
      communityCategory.image = #imageLiteral(resourceName: "infoDiffIcon1")
    case "소식":
      communityCategory.image = #imageLiteral(resourceName: "infoDiffIcon2")
    case "이벤트":
      communityCategory.image = #imageLiteral(resourceName: "infoDiffIcon3")
    case "후기":
      communityCategory.image = #imageLiteral(resourceName: "infoDiffIcon4")
    case "모집중":
      communityCategory.image = #imageLiteral(resourceName: "recruitImage")
    case "모집완료":
      communityCategory.image = #imageLiteral(resourceName: "finishRecruitImage")
    case "진행":
      communityCategory.image = #imageLiteral(resourceName: "infoDiffIcon6")
    case "마감":
      communityCategory.image = #imageLiteral(resourceName: "infoDiffIcon7")
    default:
      communityCategory.isHidden = true
      break
    }
    let scale = (communityCategory.image?.size.width ?? 0) / (communityCategory.image?.size.height ?? 0)
    communityCategoryWidth.constant = 15 * scale
    
    titleLabel.text = data.title
    
    contentTextView.text = data.content
    
    nameLabel.text = data.nickname
    dateLabel.text = data.createdAt
    //    reviewCountLabel.text = "\(data.commentCount)"
    
    let userPk = "\(DataHelperTool.userAppId ?? 0)"
    
    if userPk == data.user_pk{
      modifyButton.isHidden = false
      deleteButton.isHidden = false
    }
    
    isLike = data.isLike == "true"
    
    collectionView.reloadData()
    
    self.dismissHUD()
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
  
  func initBoardCommentList() {
    ApiService.request(router: BoardApi.boardCommentList(boardId: boardId ?? 0), success: { (response: ApiResponse<BoardCommentListResponse>) in
      guard let value = response.value else {
        return
      }
      if value.statusCode == 200 {
        self.boardCommentList = value.list ?? []
        self.initTableViewHeightWithBoardCommentList()
        self.tableView.reloadData()
        self.dismissHUD()
      } else {
        self.dismissHUD()
      }
    }) { (error) in
      self.dismissHUD()
    }
  }
  
  func registBoardComment() {
    self.showHUD()
    
    let param = BoardCommentRegistRequest(
      boardsId: boardId ?? 0,
      content: inputTextView.text!,
      boardsCommentId: sendCommentId
    )
    ApiService.request(router: BoardApi.boardCommentRegister(param: param), success: { (response: ApiResponse<DefaultResponse>) in
      guard let value = response.value else {
        return
      }
      if value.statusCode == 200 {
        self.replyLabel.text = nil
        self.sendCommentId = nil
        UIView.animate(withDuration: 0.5) {
          self.replyView.alpha = 0
          self.replyView.layoutIfNeeded()
        }
        self.inputTextView.text = self.inputTextViewPlaceHolder
        self.initBoardCommentList()
      }
    }) { (error) in
    }
  }
  
  func removeBoardComment(commentId: Int) {
    self.showHUD()
    ApiService.request(router: BoardApi.boardCommentRemover(id: commentId), success: { (response: ApiResponse<DefaultResponse>) in
      guard let value = response.value else {
        return
      }
      if value.statusCode == 200 {
        self.inputTextView.text = self.inputTextViewPlaceHolder
        self.initBoardCommentList()
      }
    }) { (error) in
    }
  }
  
  func removeBoard() {
    self.showHUD()
    ApiService.request(router: BoardApi.boardRemove(id: boardId ?? 0), success: { (response: ApiResponse<DefaultResponse>) in
      guard let value = response.value else {
        return
      }
      if value.statusCode == 200 {
        self.backPress()
      }
    }) { (error) in
    }
  }
  
  func registLike() {
    ApiService.request(router: BoardApi.registLike(boardId: boardId ?? 0), success: { (response: ApiResponse<DefaultResponse>) in
      guard let value = response.value else {
        return
      }
      if value.statusCode == 200 {
        self.boardDetail()
      } else {
        self.callMSGDialog(message: value.message)
      }
    }) { (error) in
    }
  }
  
  func removeLike() {
    ApiService.request(router: BoardApi.removeLike(boardId: boardId ?? 0), success: { (response: ApiResponse<DefaultResponse>) in
      guard let value = response.value else {
        return
      }
      if value.statusCode == 200 {
        self.boardDetail()
      }
    }) { (error) in
    }
  }
  
  @objc
  func tapCommentReply(_ sender: UIButton) {
    if let index = Int(sender.accessibilityHint!) {
      let dict = boardCommentList[index]
      
      sendCommentId = dict.id
      sendCommentName = "@\(dict.nickname) "
      
      replyLabel.text = "\(dict.nickname)"
      UIView.animate(withDuration: 0.5) {
        self.replyView.alpha = 1.0
        self.replyView.layoutIfNeeded()
      }
      
      if !inputTextView.isFirstResponder {
        inputTextView.becomeFirstResponder()
        
        inputTextView.text = nil
      }
      
    }
  }
  
  @objc
  func tapRemoveComment(_ sender: UIButton) {
    if let index = Int(sender.accessibilityHint!) {
      choiceAlert(message: "해당 댓글을 삭제하시겠습니까?") {
        self.removeBoardComment(commentId: self.boardCommentList[index].id)
      }
    }
  }
  @IBAction func backPress(_ sender: Any) {
    backPress()
  }
  
  @IBAction func tapRecommand(_ sender: UIButton) {
    if DataHelperTool.userAppId == nil {
      //      let alertController = UIAlertController(title: nil, message: "로그인 후 이용해주세요", preferredStyle: .alert)
      //      let LoginAction = UIAlertAction(title: "확인", style: .default){ (action) in
      //        self.performSegue(withIdentifier: "LoginVC", sender: self)
      //      }
      //      alertController.addAction(LoginAction)
      //      self.present(alertController, animated: true, completion: nil)
    } else{
      if isLike {
        callMSGDialog(message: "이미 좋아요한 게시물입니다.")
      } else {
        registLike()
      }
    }
  }
  
  @IBAction func tapCancleTag(_ sender: UIButton) {
    reviewTextView.text = nil
    inputTextView.text = nil
    replyLabel.text = nil
    sendCommentId = nil
    sendCommentName = nil
    
    UIView.animate(withDuration: 0.5) {
      self.replyView.alpha = 0
      self.replyView.layoutIfNeeded()
    }
  }
  
  @IBAction func registReview(_ sender: UIButton) {
    self.view.endEditing(true)
    if DataHelperTool.userAppId == nil {
      let alertController = UIAlertController(title: nil, message: "로그인 후 이용해주세요", preferredStyle: .alert)
      let LoginAction = UIAlertAction(title: "확인", style: .default){ (action) in
        self.performSegue(withIdentifier: "LoginVC", sender: self)
      }
      alertController.addAction(LoginAction)
      self.present(alertController, animated: true, completion: nil)
    }else{
      if inputTextView.text!.isCommentValidate() {
        if inputTextView.text!.isEmpty {
          callMSGDialog(message: "댓글을 입력해주세요.")
          return
        }
        
        registBoardComment()
      } else {
        self.doAlert(message: "이모티콘은 사용할 수 없습니다.\n다시 시도해 주세요.")
      }
    }
    
  }
  @IBAction func tapUserReport(_ sender: Any) {
    self.callYesNoMSGDialog(message: "해당 유저를 신고하시겠습니까?") {
      self.showToast(message: "신고 완료하였습니다.")
      DataHelper<String>.appendReportUserList(self.registUserId)
      self.backPress()
    }
  }
  
}

extension CommunityDetailViewController: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView == inputTextView {
      textViewSetupView()
    }
    
  }
  func textViewDidEndEditing(_ textView: UITextView) {
    if textView == inputTextView {
      if self.inputTextView.text == "" {
        textViewSetupView()
      }
    }
  }
  
  func textViewDidChange(_ textView: UITextView) {
    let spacing = CharacterSet.whitespacesAndNewlines
    if !textView.text.trimmingCharacters(in: spacing).isEmpty || !textView.text.isEmpty {
      textView.textColor = .black
      registCommentButton.setTitleColor(#colorLiteral(red: 1, green: 0.7247751355, blue: 0, alpha: 1), for: UIControl.State.normal)
      registCommentButton.isEnabled = true
    } else if textView.text.isEmpty {
      textView.textColor = .lightGray
      registCommentButton.isEnabled = false
      registCommentButton.setTitleColor(#colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1), for: UIControl.State.normal)
    }
    
    setTextViewHeight()
  }
}

//extension CommunityDetailViewController: UITextViewDelegate {
//  func textViewDidBeginEditing(_ textView: UITextView) {
//
//  }
//
//  func textViewDidEndEditing(_ textView: UITextView) {
//    if self.reviewTextView.text == "" {
//
//    }
//  }
//
//  func textViewDidChange(_ textView: UITextView) {
//    let spacing = CharacterSet.whitespacesAndNewlines
//    if textView == reviewTextView {
//      if sendCommentName != nil {
//        if reviewTextView.text.count < (sendCommentName?.count ?? 0) {
//          reviewTextView.text = nil
//          sendCommentId = nil
//          sendCommentName = nil
//        }
//      }
//    }
//
//    if !textView.text.trimmingCharacters(in: spacing).isEmpty || !textView.text.isEmpty {
//
//    }
//  }
//}

extension CommunityDetailViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return boardCommentList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CommunityBoardCommentListCell
    let dict = boardCommentList[indexPath.row]
    
    cell.initWithCommentList(dict)
    
    cell.deleteButton.accessibilityHint = String(indexPath.row)
    cell.deleteButton.addTarget(self, action: #selector(tapRemoveComment(_:)), for: .touchUpInside)
    
    cell.replyButton.accessibilityHint = String(indexPath.row)
    cell.replyButton.addTarget(self, action: #selector(tapCommentReply(_:)), for: .touchUpInside)
    
    cell.selectionStyle = .none
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //    let dict = feedCommentList[indexPath.row]
    
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let dict = boardCommentList[indexPath.row]
    
    let mainWidth = UIScreen.main.bounds.width
    
    let textHeight = dict.content.height(withConstrainedWidth: mainWidth - (dict.depth == "0" ? 30 : 65), font: .systemFont(ofSize: 11))
    
    return (textHeight + 59)
  }
  
}

extension CommunityDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    let page = Int(targetContentOffset.pointee.x / self.collectionView.bounds.width)
    print(page)
    //    pageControl.currentPage = page
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return boardImageList.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    guard let imageView = cell.viewWithTag(1) as? UIImageView else {
      return cell
    }
    let dict = boardImageList[indexPath.row]
    if dict.name != nil {
      imageView.kf.setImage(with: URL(string: "https://d35jysenqmci34.cloudfront.net/fit-in/\(dict.name)"))
    } else {
      imageView.image = nil
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: self.collectionView.bounds.width, height: self.collectionView.bounds.height)
  }
}
