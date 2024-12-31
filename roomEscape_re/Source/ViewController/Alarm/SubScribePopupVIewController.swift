//
//  SubScribePopupVIewController.swift
//  roomEscape_re
//
//  Created by 이남기 on 5/17/24.
//

import Foundation
import UIKit

protocol tabSub{
  func ok(success: Bool)
}
class SubScribePopupVIewController: BaseViewController{
  
  @IBOutlet var tabSub: UIButton!
  var delegate: tabSub?
  
  func initrx(){
    tabSub.rx.tapGesture().when(.recognized)
      .bind(onNext: { [weak self] _ in
        InAppProducts.store.requestProducts { success, products in
          DispatchQueue.main.async {
              self?.showHUD()
            if let product = products?.first {
              InAppProducts.store.buyProduct(product, { success in
                if success{
                  self?.dismissHUD()
                  self?.subCheck(iosReceipt: self?.getReceiptData(), result: { success in
                    self?.delegate?.ok(success: success)
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
      })
      .disposed(by: disposeBag)
  }
}
