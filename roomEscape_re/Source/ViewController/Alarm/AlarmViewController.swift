//
//  AlarmViewController.swift
//  roomEscape_re
//
//  Created by 이남기 on 4/18/24.
//

import Foundation
import UIKit

public struct InAppProducts {
  public static let product = "1000_room_sub"
  private static let productIdentifiers: Set<ProductIdentifier> = [InAppProducts.product]
  public static let store = IAPHelper(productIds: InAppProducts.productIdentifiers)
}

class AlarmViewController: BaseViewController, tabSub{
  func ok(success: Bool) {
    if success{
      subScribe.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
      subScribe.setTitle("구독중", for: .normal)
      dismissHUD()
    }else{
      showToast(message: "구독 구매 검증에 실패하였습니다.")
      dismissHUD()
    }
  }
  
  
  @IBOutlet var subProductBackView: UIView!{
    didSet{
      subProductBackView.layer.cornerRadius = 5
      subProductBackView.layer.shadowColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
      subProductBackView.layer.shadowOpacity = 1
      subProductBackView.layer.shadowOffset = CGSize(width: 0, height: 2)
      subProductBackView.layer.shadowRadius = 2
    }
  }
  @IBOutlet var subScribe: UIButton!
  @IBOutlet var subRestoreButton: UILabel!
  @IBOutlet var backPressButton: UIButton!
  @IBOutlet var termsLabel: UILabel!
  @IBOutlet var privacyLabel: UILabel!
  @IBOutlet var subCheckButton: UIImageView!
  
  var isSub: Bool = false{
    didSet{
      self.subCheckButton.image = UIImage(named: isSub ? "subCheckOn" : "subCheckOff")
    }
  }
  
  override func viewDidLoad() {
    if DataHelperTool.isSub ?? false {
      self.subScribe.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
      self.subScribe.setTitle("구독중", for: .normal)
    }
    initrx()
  }
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.navigationBar.isHidden = true
  }
  func initrx(){
    subProductBackView.rx.tapGesture().when(.recognized)
        .bind(onNext: { [weak self] _ in
          self?.isSub = !(self?.isSub ?? false)
        })
        .disposed(by: disposeBag)
    termsLabel.rx.tapGesture().when(.recognized)
        .bind(onNext: { [weak self] _ in
          let vc = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "AgreeVC") as! AgreeVC
          vc.naviTitle = "이용약관"
          self?.navigationController?.pushViewController(vc, animated: true)
        })
        .disposed(by: disposeBag)
    privacyLabel.rx.tapGesture().when(.recognized)
        .bind(onNext: { [weak self] _ in
          let vc = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "AgreeVC") as! AgreeVC
          vc.naviTitle = "개인정보처리 방침"
          self?.navigationController?.pushViewController(vc, animated: true)
        })
        .disposed(by: disposeBag)
    subRestoreButton.rx.tapGesture().when(.recognized)
        .bind(onNext: { [weak self] _ in
          InAppProducts.store.restorePurchases()
        })
        .disposed(by: disposeBag)
    backPressButton.rx.tapGesture().when(.recognized)
      .bind(onNext: {[weak self] _ in
        self?.backPress()
        })
        .disposed(by: disposeBag)
    subScribe.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        if !(self?.isSub ?? false){
          self?.showToast(message: "구독 상품을 선택해주세요.")
          return
        }
        if DataHelperTool.isSub ?? false {
          return
        }
        self?.showHUD()
        InAppProducts.store.requestProducts { success, products in
          DispatchQueue.main.async {
            if let product = products?.first {
              InAppProducts.store.buyProduct(product, { success in
                if success{
                  self?.dismissHUD()
                  self?.subCheck(iosReceipt: self?.getReceiptData(), result: { success in
                    if success{
                      self?.subScribe.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
                      self?.subScribe.setTitle("구독중", for: .normal)
                      self?.dismissHUD()
                    }else{
                      self?.showToast(message: "구독 구매 검증에 실패하였습니다.")
                      self?.dismissHUD()
                    }
                    self?.backPress()
                  })
                }else{
                  self?.dismissHUD()
                }
              })
            } else {
              self?.dismissHUD()
            }
          }
        }
//        self?.showPopup()
      })
      .disposed(by: disposeBag)
  }
  
  func showPopup() {
    let vc = self.storyboard?.instantiateViewController(withIdentifier: "SubScribePopupVIewController") as! SubScribePopupVIewController
    vc.modalPresentationStyle = .overFullScreen
    vc.modalTransitionStyle = .crossDissolve
    vc.delegate = self
    self.present(vc, animated: true, completion: nil)
  }
}
