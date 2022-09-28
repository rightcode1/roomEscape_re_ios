//
//  CustomTimePickerViewController.swift
//  ppuryoManager_ios
//
//  Created by hoonKim on 2021/11/02.
//

import UIKit

protocol CustomTimePickerViewDelegate {
  func selectTimeString(timeString: String, formmatString: String)
}

class CustomTimePickerViewController: UIViewController {
  
  @IBOutlet weak var pickerView: UIPickerView!
  
  var delegate: CustomTimePickerViewDelegate?
  
  var isTime: Bool = false
  
  var minute: Int = 0
  
  let second: Int = 60
  
  var selectedMinute: String?
  var selectedSecond: String?
  var selectedTimeFormatString: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    pickerView.delegate = self
    
    pickerView.reloadAllComponents()
  }
  
  @IBAction func tapCheck(_ sender: UIButton) {
    if selectedTimeFormatString != nil {
      backPress()
      delegate?.selectTimeString(timeString: "\(selectedMinute!)분\(selectedSecond!)초", formmatString: selectedTimeFormatString!)
    }
  }
  
}


extension CustomTimePickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 2
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    if component == 0 {
      return minute + 1
    } else {
      return second
    }
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    if component == 0 {
      return "\(row)"
    } else {
      return "\(row)"
    }
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    if row != 0 {
      let minuteIndex = self.pickerView.selectedRow(inComponent: 0)
      let secondIndex = self.pickerView.selectedRow(inComponent: 1)
      
        selectedMinute = "\(minuteIndex)"
        selectedSecond = "\(secondIndex)"
        
        selectedTimeFormatString = "\(minuteIndex):\(secondIndex)"
      print("selectedTimeFormatString: \(selectedTimeFormatString ?? "")")
    }
  }
  
}
