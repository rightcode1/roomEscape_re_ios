//
//  ViewcontrollerExtention.swift
//  FOAV
//
//  Created by hoon Kim on 02/10/2019.
//  Copyright © 2019 hoon Kim. All rights reserved.
//
import Foundation
import UIKit
import JGProgressHUD
import PopupDialog

extension UIViewController {
  var progressHUD: JGProgressHUD {
    let hud = JGProgressHUD(style: .dark)
    return hud
  }
  
  func showHUD(){
    self.progressHUD.show(in: self.view, animated: true)
    self.view.isUserInteractionEnabled = false
  }
  
  func dismissHUD(){
    JGProgressHUD.allProgressHUDs(in: self.view).forEach{ hud in
      hud.dismiss(animated: true)
    }
    self.view.isUserInteractionEnabled = true
  }
  
  func callMSGDialog(title: String? = "",message: String, buttonTitle: String? = nil) {
    let custom = PopupDialog(
      title: title,
      message: message,
      image: nil,
      buttonAlignment: NSLayoutConstraint.Axis.horizontal,
      transitionStyle: PopupDialogTransitionStyle.zoomIn,
      preferredWidth: self.view.frame.size.width - 100,
      tapGestureDismissal: true,
      panGestureDismissal: false,
      hideStatusBar: false,
      completion: nil
    )
    
    let dialogAppearance = PopupDialogDefaultView.appearance()
    dialogAppearance.messageColor = .black
    let button = DefaultButton(title: buttonTitle ?? "확인") {
      
    }
    button.titleColor = .black
    button.buttonColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    custom.addButton(button)
    self.present(custom, animated: true, completion: nil)
  }
  
  func callOkActionMSGDialog(title: String? = "", message: String, okAction: @escaping () -> Void) {
    let custom = PopupDialog(
      title: title,
      message: message,
      image: nil,
      buttonAlignment: NSLayoutConstraint.Axis.horizontal,
      transitionStyle: PopupDialogTransitionStyle.zoomIn,
      preferredWidth: self.view.frame.size.width - 100,
      tapGestureDismissal: false,
      panGestureDismissal: false,
      hideStatusBar: false,
      completion: nil
    )
    
    let dialogAppearance = PopupDialogDefaultView.appearance()
    dialogAppearance.messageColor = .black
    let button = DefaultButton(title: "확인") {
      okAction()
    }
    button.titleColor = .black
    button.buttonColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    custom.addButton(button)
    self.present(custom, animated: true, completion: nil)
  }
  
  func callYesNoMSGDialog(title: String? = "",yesButtonTitle: String? = nil, noButtonTitle: String? = nil, message: String, okAction: @escaping () -> Void) {
    let custom = PopupDialog(
      title: title,
      message: message,
      image: nil,
      buttonAlignment: NSLayoutConstraint.Axis.horizontal,
      transitionStyle: PopupDialogTransitionStyle.zoomIn,
      preferredWidth: self.view.frame.size.width - 100,
      tapGestureDismissal: false,
      panGestureDismissal: false,
      hideStatusBar: false,
      completion: nil
    )
    
    let dialogAppearance = PopupDialogDefaultView.appearance()
    dialogAppearance.messageColor = .black
    
    let noButton = DefaultButton(title: (noButtonTitle == nil ? "취소" : noButtonTitle)!) {
      
    }
    let yesButton = DefaultButton(title: (yesButtonTitle == nil ? "확인" : yesButtonTitle)!) {
      okAction()
    }
    
    noButton.titleColor = .black
    noButton.buttonColor = .white
    custom.addButton(noButton)
    
    
    yesButton.titleColor = .black
    yesButton.buttonColor = .white
    custom.addButton(yesButton)
    
    self.present(custom, animated: true, completion: nil)
  }
  
  func callYesNoActionMSGDialog(title: String? = "",yesButtonTitle: String? = nil, noButtonTitle: String? = nil, message: String, okAction: @escaping () -> Void, cancelAction: @escaping () -> Void) {
    let custom = PopupDialog(
      title: title,
      message: message,
      image: nil,
      buttonAlignment: NSLayoutConstraint.Axis.horizontal,
      transitionStyle: PopupDialogTransitionStyle.zoomIn,
      preferredWidth: self.view.frame.size.width - 100,
      tapGestureDismissal: false,
      panGestureDismissal: false,
      hideStatusBar: false,
      completion: nil
    )
    
    let dialogAppearance = PopupDialogDefaultView.appearance()
    dialogAppearance.messageColor = .black
    
    let noButton = DefaultButton(title: (noButtonTitle == nil ? "취소" : noButtonTitle)!) {
      cancelAction()
    }
    let yesButton = DefaultButton(title: (yesButtonTitle == nil ? "확인" : yesButtonTitle)!) {
      okAction()
    }
    
    noButton.titleColor = .black
    noButton.buttonColor = .white
    custom.addButton(noButton)
    
    
    yesButton.titleColor = .black
    yesButton.buttonColor = .white
    custom.addButton(yesButton)
    
    self.present(custom, animated: true, completion: nil)
  }
  
  //    func callSigninDialog() {
  //      self.callYesNoMSGDialog(message: "로그인이 필요한 화면입니다.\n로그인 하시겠습니까?") {
  //        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
  //        vc.loginDelegate = self as? LoginCheckDelegate
  //        self.goViewController(vc: vc)
  //      }
  //    }
  
  // "네" "아니오" 선택할 수 있는 얼럿 함수
  func choiceAlert(message: String, okAction: @escaping () -> Void) {
    let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
    let noAction = UIAlertAction(title: "아니요", style: UIAlertAction.Style.cancel)
    let yesAction = UIAlertAction(title: "네", style: UIAlertAction.Style.default) { (action) in
      okAction()
    }
    alert.addAction(noAction)
    alert.addAction(yesAction)
    self.present(alert, animated: true, completion: nil)
  }
  // 확인버튼 누르면 액션 이벤트하는 얼럿
  func okActionAlert(message: String, okAction: @escaping () -> Void) {
    let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
    let yesAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) {
      (action) in
      okAction()
    }
    alert.addAction(yesAction)
    self.present(alert, animated: true, completion: nil)
  }
  // 확인 버튼만 있는 얼럿 함수
  func doAlert(message: String) {
    let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
    let yesAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default)
    alert.addAction(yesAction)
    self.present(alert, animated: true, completion: nil)
  }
  
  // 토스트 함수pp
  //  func showToast(message : String, seconds: Double = 1.0) {
  //    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
  //    alert.view.backgroundColor = UIColor.black
  //    alert.view.alpha = 0.6
  //    alert.view.layer.cornerRadius = 15
  //
  //    self.present(alert, animated: true)
  //
  //    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
  //      alert.dismiss(animated: true)
  //    }
  //  }
  
  func showToast(message : String, font: UIFont? = UIFont.systemFont(ofSize: 14)) {
    let toastLabel = UILabel(frame: CGRect(x: (self.view.frame.size.width/2) - 125, y: self.view.frame.size.height-100, width: 250, height: 38))
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    toastLabel.textColor = UIColor.white
    toastLabel.font = font
    toastLabel.textAlignment = .center;
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 12;
    toastLabel.clipsToBounds = true
    self.view.addSubview(toastLabel)
    UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
      toastLabel.alpha = 0.0
    },
    completion: { (isCompleted) in
      toastLabel.removeFromSuperview()
    })
  }
  
  
  // 네비게이션 바 타이틀 UI 넣어주는 함수
  func navigationTitleUI(_ image: UIImage) {
    let logoView = UIView(frame: CGRect(x: 0, y: 0, width: 100 , height: 40))
    
    let logo = UIImageView(frame: CGRect(x: 0, y: 0, width: 100 , height: 40))
    logo.contentMode = .scaleAspectFit
    
    logo.image = image
    logoView.addSubview(logo)
    self.navigationItem.titleView = logoView
  }
  
  func shadow(view: UIView, radius: CGFloat, offset: CGSize) {
    view.layer.cornerRadius = radius
    view.layer.shadowColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    view.layer.shadowOpacity = 1
    view.layer.shadowOffset = offset
    view.layer.shadowRadius = 2
  }
  
  func setDropBorder(view: UIView) {
    view.layer.borderColor = #colorLiteral(red: 0.9152902961, green: 0.9086738825, blue: 0.9203559756, alpha: 1)
    view.layer.borderWidth = 0.5
    view.layer.cornerRadius = 6
  }
  
  func moveToLogin() {
    let vc = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "LoginNC")
    vc.modalPresentationStyle = .fullScreen
    self.present(vc, animated: true, completion: nil)
  }
  
  func goTabBar() {
    let vc = UIStoryboard.init(name: "TabBar", bundle: nil).instantiateViewController(withIdentifier: "tabBar") as! TabBarViewController
    vc.modalPresentationStyle = .fullScreen
    vc.selectedIndex = 2
    self.present(vc, animated: true, completion: nil)
  }
  
  
  @IBAction func backPress(){
    if let navigationController = navigationController{
      if let rootViewController = navigationController.viewControllers.first, rootViewController.isEqual(self){
        dismiss(animated: true, completion: nil)
      }else{
        navigationController.popViewController(animated: true)
      }
    }else{
      dismiss(animated: true, completion: nil)
    }
  }
  
  @IBAction func rootBackPress() {
    if let navigationController = navigationController {
      if let rootViewController = navigationController.viewControllers.first, rootViewController.isEqual(self) {
        dismiss(animated: true, completion: nil)
      } else {
        self.navigationController?.popToRootViewController(animated: true)
      }
    } else {
      dismiss(animated: true, completion: nil)
    }
  }
  
}

