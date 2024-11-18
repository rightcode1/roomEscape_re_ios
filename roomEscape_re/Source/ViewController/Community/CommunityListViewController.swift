//
//  CommunityListViewController.swift
//  room_escape
//
//  Created by hoonKim on 2021/06/13.
//  Copyright © 2021 park. All rights reserved.
//

import UIKit
class CommunityListViewController: BaseViewController,UIScrollViewDelegate {
  @IBOutlet var collectionView: UICollectionView!
  
  @IBOutlet var tableView: UITableView!
  
//  @IBOutlet var diffLabel: UILabel!
  var page: Int = 1
  var check: Bool = false
  
  @IBOutlet var selectView0: UIView!
  @IBOutlet var selectView1: UIView!
  @IBOutlet var selectView2: UIView!
  @IBOutlet var selectView3: UIView!
  @IBOutlet var selectView4: UIView!
  
  @IBOutlet var searchView: UIView!
  @IBOutlet var searchNavigationView: UIView!
  //  @IBOutlet var initSearchButton: UIButton!
  @IBOutlet var searchTextField: UITextField!
  
  @IBOutlet var categoryView: UIView!
  @IBOutlet var categoryHeightView: NSLayoutConstraint!
  @IBOutlet var categoryStackView: UIStackView!
  
  @IBOutlet var categoryView1: UIView!
  @IBOutlet var categoryLabel1: UILabel!
  @IBOutlet var categoryView2: UIView!
  @IBOutlet var categoryLabel2: UILabel!
  @IBOutlet var categoryView3: UIView!
  @IBOutlet var categoryLabel3: UILabel!
  @IBOutlet var categoryView4: UIView!
  @IBOutlet var categoryLabel4: UILabel!
  
  
  @IBOutlet var registBoardButton: UIImageView!
  
  var isMine: Bool = false
  var isSearch: Bool = false
  var reportList: [Int] = []
  var userReportList: [String] = []
  
  let cellIdentifier: String = "CommunityBoardListCell"
  
  var selectBoardCategory: BoardCategory? = nil{
    didSet{
      page = 1
      setNotSelectCategory(categoryView1,categoryLabel1)
      setNotSelectCategory(categoryView2,categoryLabel2)
      setNotSelectCategory(categoryView3,categoryLabel3)
      setNotSelectCategory(categoryView4,categoryLabel4)
      switch selectBoardCategory {
      case .정보:
        setSelectCategory(categoryView1,categoryLabel1)
      case .소식:
        setSelectCategory(categoryView2,categoryLabel2)
      case .이벤트:
        setSelectCategory(categoryView3,categoryLabel3)
      case .후기:
        setSelectCategory(categoryView4,categoryLabel4)
      case .모집중:
        setSelectCategory(categoryView2,categoryLabel2)
      case .모집완료:
        setSelectCategory(categoryView3,categoryLabel3)
      case .진행:
        setSelectCategory(categoryView2,categoryLabel2)
      case .마감:
        setSelectCategory(categoryView3,categoryLabel3)
      case .최신순:
        setSelectCategory(categoryView1,categoryLabel1)
      case .추천순:
        setSelectCategory(categoryView2,categoryLabel2)
      case nil:
        setSelectCategory(categoryView1,categoryLabel1)
      default:
        break
      }
    }
  }
  
  var boardDiff: BoardDiff = .양도교환 {
    didSet {
      page = 1
      selectView0.isHidden = boardDiff == .양도교환 ? false : true
      selectView1.isHidden = boardDiff == .자유게시판 ? false : true
      selectView2.isHidden = boardDiff == .보드판갤러리 ? false : true
      collectionView.isHidden = boardDiff == .보드판갤러리 ? false : true
      tableView.isHidden = boardDiff == .보드판갤러리
      selectView3.isHidden = boardDiff == .일행구하기 ? false : true
      selectView4.isHidden = boardDiff == .방탈출정보 ? false : true
      categoryView.isHidden = boardDiff == .자유게시판 || isMine ? true : false
      categoryView1.isHidden = true
      categoryView2.isHidden = true
      categoryView3.isHidden = true
      categoryView4.isHidden = true
      categoryView.isHidden = false
      switch boardDiff{
      case .양도교환:
        categoryView1.isHidden = false
        categoryView2.isHidden = false
        categoryView3.isHidden = false
        categoryLabel1.text = "전체"
        categoryLabel2.text = "진행"
        categoryLabel3.text = "마감"
      case .일행구하기:
        categoryView1.isHidden = false
        categoryView2.isHidden = false
        categoryView3.isHidden = false
        categoryLabel1.text = "전체"
        categoryLabel2.text = "모집중"
        categoryLabel3.text = "모집완료"
      case .보드판갤러리:
        categoryView1.isHidden = false
        categoryView2.isHidden = false
        categoryLabel1.text = "최신순"
        categoryLabel2.text = "추천순"
      case .방탈출정보:
        categoryView1.isHidden = false
        categoryView2.isHidden = false
        categoryView3.isHidden = false
        categoryView4.isHidden = false
        categoryLabel1.text = "정보"
        categoryLabel2.text = "소식"
        categoryLabel3.text = "이벤트"
        categoryLabel4.text = "후기"
      default:
        categoryView.isHidden = true
        break
      }
    }
  }
  
  var boardList: [BoardList] = [] {
    didSet {
      collectionView.reloadData()
      tableView.reloadData()
      if boardDiff != .보드판갤러리 {
        collectionView.isHidden = true
      } else {
        tableView.isHidden = true
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    page = 1
    registerXib()
    initrx()
    setSelectCategory(categoryView1,categoryLabel1)
    tableView.dataSource = self
    tableView.delegate = self
    collectionView.dataSource = self
    collectionView.delegate = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.navigationBar.isHidden = false
    check = false
    page = 1
    boardList.removeAll()
    if isSearch || isMine{
      searchView.isHidden = false
      searchNavigationView.isHidden = false
      navigationController?.navigationBar.isHidden = true
    }else{
      initBoardList()
    }
    searchTextField.delegate = self
  }
  private func registerXib() {
    let nibName = UINib(nibName: cellIdentifier, bundle: nil)
    tableView.register(nibName, forCellReuseIdentifier: cellIdentifier)
  }
  
  func setSelectCategory(_ view: UIView,_ textView : UILabel) {
    view.backgroundColor = UIColor(red: 255, green: 239, blue: 188)
    view.borderColor = .clear
    textView.textColor = UIColor(red: 255, green: 162, blue: 0)
  }
  
  func setNotSelectCategory(_ view: UIView,_ textView: UILabel) {
    view.backgroundColor = .white
    view.borderColor = #colorLiteral(red: 0.9294117093, green: 0.9294117093, blue: 0.9294117093, alpha: 1)
    textView.textColor = .lightGray
  }
  
//  func initTableViewHeightWithBoardList() {
////    self.tableViewHeight.constant = self.tableView.contentSize.height
//    tableViewHeight.constant = CGFloat(boardList.count * 77)
//  }
  
//  func initCollectionViewHeightWithBoardList() {
//    collectionViewHeight.constant = CGFloat(((boardList.count / 2) + (boardList.count % 2 != 0 ? 1 : 0)) * 228)
//  }
  
  
  func initBoardList(_ searchKeyword: String? = nil) {
    let param = BoardListRequest(
      page: page, limit: 20,
      diff: boardDiff,
      category:  boardDiff == .자유게시판 || boardDiff == .보드판갤러리 ? nil : selectBoardCategory?.rawValue,
      sort: boardDiff == .보드판갤러리 ? selectBoardCategory?.rawValue : nil,
      user_pk: isMine ? DataHelperTool.userAppId ?? 0 : nil,
      search: searchKeyword
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
  
//  @IBAction func tapInitSearch(_ sender: UIButton) {
//    searchTextField.text = nil
//    self.view.endEditing(true)
//    initBoardList()
//  }
  
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
    registBoardButton.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        let vc = UIStoryboard.init(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "RegistCommunityBoardViewController") as! RegistCommunityBoardViewController
        self?.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)
    
    categoryLabel1.rx.tapGesture().when(.recognized)
        .bind(onNext: { [weak self] _ in
          if let category = BoardCategory(rawValue: self?.categoryLabel1.text ?? "") {
              self?.selectBoardCategory = category
            } else {
              self?.selectBoardCategory = nil
          }
          self?.boardList.removeAll()
          self?.initBoardList()
        })
        .disposed(by: disposeBag)
    categoryLabel2.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        if let category = BoardCategory(rawValue: self?.categoryLabel2.text ?? "") {
            self?.selectBoardCategory = category
          } else {
            self?.selectBoardCategory = nil
        }
        self?.boardList.removeAll()
        self?.initBoardList()
      })
      .disposed(by: disposeBag)
    categoryLabel3.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        if let category = BoardCategory(rawValue: self?.categoryLabel3.text ?? "") {
            self?.selectBoardCategory = category
          } else {
            self?.selectBoardCategory = nil
        }
        self?.boardList.removeAll()
        self?.initBoardList()
      })
      .disposed(by: disposeBag)
    categoryLabel4.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        if let category = BoardCategory(rawValue: self?.categoryLabel4.text ?? "") {
            self?.selectBoardCategory = category
          } else {
            self?.selectBoardCategory = nil
        }
        self?.boardList.removeAll()
        self?.initBoardList()
      })
      .disposed(by: disposeBag)
  }
  @IBAction func search(_ sender: Any) {
    initBoardList(searchTextField.text)
  }
  @IBAction func tapSearch(_ sender: Any) {
    let vc = UIStoryboard.init(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "communityListVC") as! CommunityListViewController
    vc.isSearch = true
    vc.hidesBottomBarWhenPushed = true
    self.navigationController?.pushViewController(vc, animated: true)
  }
  @IBAction func tapDiff0(_ sender: Any) {
    selectBoardCategory = nil
    boardDiff = .양도교환
    check = false
    page = 1
    boardList.removeAll()
    initBoardList()
  }
  
  @IBAction func tapDiff1(_ sender: UIButton) {
    selectBoardCategory = nil
    boardDiff = .일행구하기
    check = false
    page = 1
    boardList.removeAll()
    initBoardList()
  }
  
  @IBAction func tapDiff2(_ sender: UIButton) {
    selectBoardCategory = nil
    boardDiff = .자유게시판
    check = false
    page = 1
    boardList.removeAll()
    initBoardList()
  }
  
  @IBAction func tapDiff3(_ sender: UIButton) {
    selectBoardCategory = .최신순
    boardDiff = .보드판갤러리
    check = false
    page = 1
    boardList.removeAll()
    initBoardList()
  }
  
  @IBAction func tapDiff4(_ sender: UIButton) {
    selectBoardCategory = nil
    boardDiff = .방탈출정보
    check = false
    page = 1
    boardList.removeAll()
    initBoardList()
  }
  @IBAction func backPress(_ sender: Any) {
    backPress()
  }
}

extension CommunityListViewController: UITableViewDelegate, UITableViewDataSource {
  
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
    let vc = UIStoryboard.init(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "communityDetail") as! CommunityDetailViewController
    vc.boardId = dict.id
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
}

// MARK: - CollectionView
extension CommunityListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
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
    let vc = UIStoryboard.init(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "communityDetail") as! CommunityDetailViewController
    vc.boardId = dict.id
    self.navigationController?.pushViewController(vc, animated: true)
  }
}

extension CommunityListViewController: UICollectionViewDelegateFlowLayout {
  
  
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

extension CommunityListViewController: UITextFieldDelegate{
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    if !textField.text!.isEmpty {
      self.initBoardList(searchTextField.text)
    }
    return true
  }
}
