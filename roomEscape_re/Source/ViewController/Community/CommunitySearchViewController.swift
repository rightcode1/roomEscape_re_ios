//
//  CommunitySearchViewController.swift
//  roomEscape_re
//
//  Created by 이남기 on 2023/06/08.
//

import Foundation
class CommunitySearchViewController: BaseViewController,UIScrollViewDelegate {
  
  @IBOutlet var scrollView: UIScrollView!
  
  @IBOutlet var collectionView: UICollectionView!
  @IBOutlet var collectionViewHeight: NSLayoutConstraint!
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var tableViewHeight: NSLayoutConstraint!
  
//  @IBOutlet var diffLabel: UILabel!
  var page: Int = 1
  var check: Bool = false
  
  @IBOutlet var selectView1: UIView!
  @IBOutlet var selectView2: UIView!
  @IBOutlet var selectView3: UIView!
  @IBOutlet var selectView4: UIView!
  
//  @IBOutlet var initSearchButton: UIButton!
  
  @IBOutlet var categoryView: UIView!
  @IBOutlet var categoryStackView: UIStackView!
  
  @IBOutlet var sortButton1: UIView!
  @IBOutlet var sorLabel1: UILabel!
  @IBOutlet var sortButton2: UIView!
  @IBOutlet var sortLabel2: UILabel!
  
  @IBOutlet var wholeRecruitButton: UIView!
  @IBOutlet var wholeLabel: UILabel!
  @IBOutlet var recruitButton: UIView!
  @IBOutlet var recruitLabel: UILabel!
  @IBOutlet var finishRecruitButton: UIView!
  @IBOutlet var finishRecruitLabel: UILabel!
  
  @IBOutlet var infoCategoryButton1: UIView!
  @IBOutlet var infoLabel1: UILabel!
  @IBOutlet var infoCategoryButton2: UIView!
  @IBOutlet var infoLabel2: UILabel!
  @IBOutlet var infoCategoryButton3: UIView!
  @IBOutlet var infoLabel3: UILabel!
  @IBOutlet var infoCategoryButton4: UIView!
  @IBOutlet var infoLabel4: UILabel!
  @IBOutlet var searchTextField: UITextField!
  
  var tabCommunityBoardId: Int?
  var isMine: Bool = false
  var reportList: [Int] = []
  var userReportList: [String] = []
  
  let cellIdentifier: String = "CommunityBoardListCell"
  
  var boardDiff: BoardDiff = .자유게시판 {
    didSet {
//      diffLabel.text = boardDiff.rawValue
      
      selectView1.isHidden = boardDiff == .자유게시판 ? false : true
      
      selectView2.isHidden = boardDiff == .보드판갤러리 ? false : true
      collectionView.isHidden = boardDiff == .보드판갤러리 ? false : true
      tableView.isHidden = boardDiff == .보드판갤러리
      
      selectView3.isHidden = boardDiff == .일행구하기 ? false : true
      
      selectView4.isHidden = boardDiff == .방탈출정보 ? false : true
      
      categoryView.isHidden = boardDiff == .자유게시판 || isMine ? true : false
      
      categoryStackView.arrangedSubviews[0].isHidden = boardDiff == .보드판갤러리 ? false : true
      categoryStackView.arrangedSubviews[1].isHidden = boardDiff == .일행구하기 ? false : true
      categoryStackView.arrangedSubviews[2].isHidden = boardDiff == .방탈출정보 ? false : true
    }
  }
  
  var boardList: [BoardList] = [] {
    didSet {
      if boardDiff != .보드판갤러리 {
        collectionViewHeight.constant = 0
        initTableViewHeightWithBoardList()
      } else {
        tableViewHeight.constant = 0
        initCollectionViewHeightWithBoardList()
      }
    }
  }
  
  var category: String = "전체" {
    didSet{
      initCategoryButtonWithCategory()
    }
  }
  
  var sortDiff: String = "최신순" {
    didSet{
      initSortButtonWithSortDiff()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    registerXib()
    initrx()
    scrollView.delegate = self
    boardList.removeAll()
    
    tableView.dataSource = self
    tableView.delegate = self
    collectionView.dataSource = self
    collectionView.delegate = self
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.isNavigationBarHidden = true
    check = false
    page = 1
    boardList.removeAll()
    if tabCommunityBoardId != nil {
      performSegue(withIdentifier: "detail", sender: tabCommunityBoardId!)
      tabCommunityBoardId = nil
    }
//    initBoardList()
//    initWithIsMine()
  }
  override func viewWillDisappear(_ animated: Bool) {
    
      navigationController?.isNavigationBarHidden = false
  }
  
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "detail", let vc = segue.destination as? CommunityDetailViewController, let boardId = sender as? Int {
      vc.boardId = boardId
    }
    
    if segue.identifier == "regist", let vc = segue.destination as? RegistCommunityBoardViewController {
      vc.boardDiff = boardDiff
      vc.boardId = nil
    }
  }
  
  private func registerXib() {
    let nibName = UINib(nibName: cellIdentifier, bundle: nil)
    tableView.register(nibName, forCellReuseIdentifier: cellIdentifier)
  }
//
//  func initWithIsMine() {
//    registBoardButton.isHidden = isMine
////    categoryView.isHidden = boardDiff == .자유게시판 || isMine ? true : false
//  }
  
  func setSelectButtonColor(_ button: UIView,_ textView : UILabel) {
    button.backgroundColor = UIColor(red: 255, green: 239, blue: 188)
    button.borderColor = .clear
    textView.textColor = UIColor(red: 255, green: 162, blue: 0)
  }
  
  func setNotSelectButtonColor(_ button: UIView,_ textView: UILabel) {
    button.backgroundColor = .white
    button.borderColor = .lightGray
    textView.textColor = .lightGray
  }
  
  func initTableViewHeightWithBoardList() {
    tableViewHeight.constant = CGFloat(boardList.count * 77)
  }
  
  func initCollectionViewHeightWithBoardList() {
    collectionViewHeight.constant = CGFloat(((boardList.count / 2) + (boardList.count % 2 != 0 ? 1 : 0)) * 228)
  }
  
  func initCategoryButtonWithCategory() {
    if boardDiff == .일행구하기 {
      if category == "전체" {
        setSelectButtonColor(wholeRecruitButton,wholeLabel)
        setNotSelectButtonColor(recruitButton,recruitLabel)
        setNotSelectButtonColor(finishRecruitButton,finishRecruitLabel)
      } else if category == "모집중" {
        setSelectButtonColor(recruitButton,recruitLabel)
        setNotSelectButtonColor(wholeRecruitButton,wholeLabel)
        setNotSelectButtonColor(finishRecruitButton,finishRecruitLabel)
      } else {
        setSelectButtonColor(finishRecruitButton,finishRecruitLabel)
        setNotSelectButtonColor(recruitButton,recruitLabel)
        setNotSelectButtonColor(wholeRecruitButton,wholeLabel)
      }
    } else {
      if category == "정보" {
        setSelectButtonColor(infoCategoryButton1,infoLabel1)
        setNotSelectButtonColor(infoCategoryButton2,infoLabel2)
        setNotSelectButtonColor(infoCategoryButton3,infoLabel3)
        setNotSelectButtonColor(infoCategoryButton4,infoLabel4)
      } else if category == "소식" {
        setSelectButtonColor(infoCategoryButton2,infoLabel2)
        setNotSelectButtonColor(infoCategoryButton3,infoLabel3)
        setNotSelectButtonColor(infoCategoryButton4,infoLabel4)
        setNotSelectButtonColor(infoCategoryButton1,infoLabel1)
      }else if category == "이벤트" {
        setSelectButtonColor(infoCategoryButton3,infoLabel3)
        setNotSelectButtonColor(infoCategoryButton2,infoLabel2)
        setNotSelectButtonColor(infoCategoryButton1,infoLabel1)
        setNotSelectButtonColor(infoCategoryButton4,infoLabel4)
      } else if category == "후기" {
        setSelectButtonColor(infoCategoryButton4,infoLabel4)
        setNotSelectButtonColor(infoCategoryButton2,infoLabel2)
        setNotSelectButtonColor(infoCategoryButton3,infoLabel3)
        setNotSelectButtonColor(infoCategoryButton1,infoLabel1)
      }
    }
  }
  
  func initSortButtonWithSortDiff() {
    if sortDiff == "최신순" {
      setSelectButtonColor(sortButton1,sorLabel1)
      setNotSelectButtonColor(sortButton2,sortLabel2)
    } else {
      setSelectButtonColor(sortButton2,sortLabel2)
      setNotSelectButtonColor(sortButton1,sorLabel1)
    }
  }
  
  
  func initBoardList() {
    let param = BoardListRequest(
      page: page, limit: 20,
      diff: boardDiff,
      category: boardDiff == .자유게시판 || boardDiff == .보드판갤러리 ? nil : category,
      sort: boardDiff == .보드판갤러리 ? sortDiff : nil,
      user_pk: isMine ? DataHelperTool.userAppId ?? 0 : nil,
      search: searchTextField.text ?? ""
    )
    self.showHUD()
    ApiService.request(router: BoardApi.boardList(param: param), success: { (response: ApiResponse<BoardListResponse>) in
      guard let value = response.value else {
        return
      }
      if value.statusCode == 200 {
//        self.initSearchButton.isHidden = searchKeyword == nil
        self.reportList = DataHelperTool.reportList
        self.userReportList = DataHelperTool.reportUserList
        
        
        if !self.reportList.isEmpty {
          for board in value.list.rows {
            if self.boardList.filter({ $0.id == board.id }).count <= 0 {
              self.boardList.append(board)
            }
          }
          for id in self.reportList {
            self.boardList = self.boardList.filter({ $0.id != id })
          }
          for userPk in self.userReportList{
            self.boardList = self.boardList.filter({ $0.user_pk != userPk })
          }
        }else{
          self.boardList.append(contentsOf: value.list.rows)
        }
        
        
        
        if self.boardDiff == .보드판갤러리 {
          self.collectionView.reloadData()
        } else {
          self.tableView.reloadData()
        }
        if(self.boardList.count == value.list.count - self.reportList.count){
          self.check = false
        }else{
          self.check = true
        }
        self.dismissHUD()
        self.view.endEditing(true)
      } else {
        self.dismissHUD()
      }
    }) { (error) in
      self.dismissHUD()
    }
  }
  
  @IBAction func tapInitSearch(_ sender: UIButton) {
    boardList.removeAll()
    self.view.endEditing(true)
    initBoardList()
  }
  
//  @IBAction func tapSearch(_ sender: UIButton) {
//    if !searchTextField.text!.isEmpty {
//      check = false
//      page = 1
//      boardList.removeAll()
//      initBoardList(searchTextField.text!)
//    } else {
//      check = false
//      page = 1
//      boardList.removeAll()
//      initBoardList()
//    }
//  }
  
  func initrx(){
      sortButton1.rx.tapGesture().when(.recognized)
        .bind(onNext: { [weak self] _ in
          self?.sortDiff = "최신순"
          self?.boardList.removeAll()
          self?.initBoardList()
        })
        .disposed(by: disposeBag)
    sortButton2.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        self?.sortDiff = "추천순"
        self?.boardList.removeAll()
        self?.initBoardList()
      })
      .disposed(by: disposeBag)
    wholeRecruitButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        self?.category = "전체"
        self?.boardList.removeAll()
        self?.initBoardList()
      })
      .disposed(by: disposeBag)
    recruitButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        self?.category = self?.boardDiff == .일행구하기 ? "모집중" : "공지"
        self?.boardList.removeAll()
        self?.initBoardList()
      })
      .disposed(by: disposeBag)
    finishRecruitButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        self?.category = self?.boardDiff == .일행구하기 ? "모집완료" : "정보"
        self?.boardList.removeAll()
        self?.initBoardList()
      })
      .disposed(by: disposeBag)
    infoCategoryButton1.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        self?.category = "정보"
        self?.boardList.removeAll()
        self?.initBoardList()
      })
      .disposed(by: disposeBag)
    infoCategoryButton2.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        self?.category = "소식"
        self?.boardList.removeAll()
        self?.initBoardList()
      })
      .disposed(by: disposeBag)
    infoCategoryButton3.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        self?.category = "이벤트"
        self?.boardList.removeAll()
        self?.initBoardList()
      })
      .disposed(by: disposeBag)
    infoCategoryButton4.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        self?.category = "후기"
        self?.boardList.removeAll()
        self?.initBoardList()
      })
      .disposed(by: disposeBag)
  }
  
  @IBAction func tapDiff1(_ sender: UIButton) {
    boardDiff = .자유게시판
    check = false
    page = 1
    boardList.removeAll()
    initBoardList()
  }
  
  @IBAction func tapDiff2(_ sender: UIButton) {
    boardDiff = .보드판갤러리
    check = false
    category = "최신순"
    page = 1
    boardList.removeAll()
    initBoardList()
  }
  
  @IBAction func tapDiff3(_ sender: UIButton) {
    boardDiff = .일행구하기
    check = false
    category = "전체"
    page = 1
    boardList.removeAll()
    initBoardList()
  }
  
  @IBAction func tapDiff4(_ sender: UIButton) {
    boardDiff = .방탈출정보
    check = false
    category = "정보"
    page = 1
    boardList.removeAll()
    initBoardList()
  }
}

extension CommunitySearchViewController: UITableViewDelegate, UITableViewDataSource {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.contentOffset.y > scrollView.contentSize.height-scrollView.bounds.size.height {
      if(check){
        page += 1
        check = false
        initBoardList()
        
      }
    }
    
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return boardList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CommunityBoardListCell
    let dict = boardList[indexPath.row]
    
    cell.initWithBoardList(dict)
    
    cell.selectionStyle = .none
    
    return cell
  }
  
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let dict = boardList[indexPath.row]
    performSegue(withIdentifier: "detail", sender: dict.id)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 77
  }
  
}

// MARK: - CollectionView
extension CommunitySearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return boardList.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    let dict = boardList[indexPath.row]
    
    guard let thumbnailImageView = cell.viewWithTag(1) as? UIImageView,
          let titleLabel = cell.viewWithTag(2) as? UILabel,
          let contentLabel = cell.viewWithTag(3) as? UILabel,
          let gradeImageView = cell.viewWithTag(4) as? UIImageView,
          let nameLabel = cell.viewWithTag(5) as? UILabel,
          let dateLabel = cell.viewWithTag(6) as? UILabel,
          let wishCountLabel = cell.viewWithTag(7) as? UILabel else { return cell }
    
    //    cell.contentView.layer.cornerRadius = 8.0
    //    cell.contentView.layer.borderWidth = 1.0
    //    cell.contentView.layer.borderColor = UIColor.clear.cgColor
    //    cell.contentView.layer.masksToBounds = true
    //
    //    cell.layer.shadowColor = UIColor.lightGray.cgColor
    //    cell.layer.shadowOffset = CGSize(width: 0, height: 1.0)
    //    cell.layer.shadowRadius = 2.0
    //    cell.layer.shadowOpacity = 1.0
    //    cell.layer.masksToBounds = false
    //    cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
    
    thumbnailImageView.kf.setImage(with: URL(string: "https://d35jysenqmci34.cloudfront.net/\(dict.thumbnail ?? "")"))
    //    "[\(dict.dong)] " +
    titleLabel.text = dict.themeName
    contentLabel.text = dict.company_name
    
    
    gradeImageView.image = UIImage(named: "BigLevel\(dict.grade)")
    
    nameLabel.text = dict.nickname
    
    dateLabel.text = dict.createdAt
    wishCountLabel.text = "\(dict.likeCount)"
    
    return cell
    
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let dict = boardList[indexPath.row]
    performSegue(withIdentifier: "detail", sender: dict.id)
  }
}

extension CommunitySearchViewController: UICollectionViewDelegateFlowLayout {
  
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
  }
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    let width = ((UIScreen.main.bounds.width - 50) / 2)
    return CGSize(width: width, height: 218)
    
  }
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 10
  }
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 10
  }
  
}
