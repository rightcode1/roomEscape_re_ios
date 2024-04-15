//
//  MyVC.swift
//  roomEscape_re
//
//  Created by RightCode_IOS on 2021/12/09.
//

import UIKit

class MyVC: BaseViewController {
  @IBOutlet var gradeImageView: UIImageView!
  @IBOutlet var userNameLabel: UILabel!
  
  @IBOutlet var myReviewView: UIView!
  @IBOutlet var otherReviewView: UIView!
  @IBOutlet var noticeView: UIView!
  
  @IBOutlet var kakaoTalkView: UIView!
  @IBOutlet var settingView: UIView!
  
  
  @IBOutlet var myBoardView: UIView!
  @IBOutlet var hintView: UIView!
  
  @IBOutlet var yesHintView: UIView!
  @IBOutlet var hintReviewCount: UILabel!
  @IBOutlet var hintRate: UILabel!
  
  @IBOutlet var yeshintTitle: UILabel!
  @IBOutlet var nohintTitle: UILabel!
  
  @IBOutlet var noHintView: UIView!
  @IBOutlet var noHintReviewCount: UILabel!
  @IBOutlet var noHintRate: UILabel!
  
  @IBOutlet var graduationView: UIView!
  @IBOutlet var deleteView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    bindInput()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.navigationBar.isHidden = true
    initUI()
  }
  
  func moveToReviewVC(isOther: Bool) {
    let vc = UIStoryboard.init(name: "My", bundle: nil).instantiateViewController(withIdentifier: "MyReviewListVC") as! MyReviewListVC
    vc.isOther = isOther
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  
  
  func initUI() {
    self.userInfo { value in
      guard let data = value.data else {
        self.hintView.isHidden = true
        self.gradeImageView.image = UIImage(named: "noneProfile")
        self.userNameLabel.text = "로그인이 필요합니다."
        return
      }
      self.hintView.isHidden = false
      self.yeshintTitle.roundCorners(corners: [.topLeft,.topRight], radius: 10)
      self.nohintTitle.roundCorners(corners: [.topLeft,.topRight], radius: 10)
      self.shadow(view: self.yesHintView, radius: 10, offset: CGSize(width: 0, height: 2))
      self.shadow(view: self.noHintView, radius: 10, offset: CGSize(width: 0, height: 2))
      
      self.hintRate.text = "\(value.data?.successRate ?? 0)%"
      self.hintReviewCount.text = "성공테마 리뷰 : \(value.data?.successReviewCount ?? 0)\n작성테마 리뷰 : \(value.data?.reviewCount ?? 0)"
      
      
      self.noHintRate.text = "\(value.data?.noHintSuccessRate ?? 0)%"
      self.noHintReviewCount.text = "노힌트한 테마리뷰 : \(value.data?.noHintSuccessReviewCount ?? 0)\n작성테마 리뷰 : \(value.data?.reviewCount ?? 0)"
      
      self.gradeImageView.image = UIImage(named: "userLevelImage\(1)")
      self.userNameLabel.text = data.name
    }
  }
  
  func bindInput() {
    myBoardView.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        let vc = UIStoryboard.init(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "communityListVC") as! CommunityListViewController
        vc.isMine = true
        vc.hidesBottomBarWhenPushed = true
        self?.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)
    myReviewView.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        self?.moveToReviewVC(isOther: false)
      })
      .disposed(by: disposeBag)
    
    otherReviewView.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        self?.moveToReviewVC(isOther: true)
      })
      .disposed(by: disposeBag)
    
    noticeView.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        let vc = UIStoryboard.init(name: "My", bundle: nil).instantiateViewController(withIdentifier: "NoticeListVC") as! NoticeListVC
        self?.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)
    
    kakaoTalkView.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        if let url = URL(string: "http://pf.kakao.com/_JxmVGb/chat") {
          UIApplication.shared.open(url, options: [:])
        }
      })
      .disposed(by: disposeBag)
    
    settingView.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        let vc = UIStoryboard.init(name: "My", bundle: nil).instantiateViewController(withIdentifier: "SettingVC") as! SettingVC
        self?.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)
    graduationView.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        let vc = UIStoryboard.init(name: "My", bundle: nil).instantiateViewController(withIdentifier: "GraduationChartVC") as! GraduationChartVC
        self?.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)
    
    deleteView.rx.tapGesture().when(.recognized)
    .bind(onNext: { [weak self] _ in
      let vc = UIStoryboard.init(name: "My", bundle: nil).instantiateViewController(withIdentifier: "DeleteThemeVC") as! DeleteThemeVC
      self?.navigationController?.pushViewController(vc, animated: true)
    })
    .disposed(by: disposeBag)
  }
  
}
