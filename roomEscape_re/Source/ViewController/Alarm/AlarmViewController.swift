//
//  AlarmViewController.swift
//  roomEscape_re
//
//  Created by 이남기 on 4/18/24.
//

import Foundation

public struct InAppProducts {
  public static let product = "room_1000_sub"
  private static let productIdentifiers: Set<ProductIdentifier> = [InAppProducts.product]
  public static let store = IAPHelper(productIds: InAppProducts.productIdentifiers)
}

class AlarmViewController: BaseViewController{
  
  @IBOutlet var subScribe: UIButton!
  @IBOutlet var subRestoreButton: UILabel!
  
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
    subRestoreButton.rx.tapGesture().when(.recognized)
        .bind(onNext: { [weak self] _ in
          InAppProducts.store.restorePurchases()
        })
        .disposed(by: disposeBag)
    subScribe.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        if DataHelperTool.isSub ?? false {
          return
        }
        InAppProducts.store.requestProducts { success, products in
          DispatchQueue.main.async {
              self?.showHUD()
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
      })
      .disposed(by: disposeBag)
  }
}
