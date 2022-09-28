//
//  SelectCalendarDateViewController.swift
//  ppuryoManager_ios
//
//  Created by hoonKim on 2021/10/09.
//

import UIKit
import FSCalendar

protocol SelectCalendarDateDelegate {
  func setDateString(dateString: String)
}

protocol SelectPaymentDateDelegate {
  func setPaymentDateString(isStartDate: Bool, dateString: String)
}

class SelectCalendarDateViewController: UIViewController {
  
  @IBOutlet weak var calendar: FSCalendar!
  
  var delegate: SelectCalendarDateDelegate?
  
  var paymentDelegate: SelectPaymentDateDelegate?
  
  var dateString: String?
  
  var selectedDate: Date?{
    didSet{
      let todayDateFormatter = DateFormatter()
      todayDateFormatter.dateFormat = "yyyy-MM-dd"
      dateString = todayDateFormatter.string(from: selectedDate ?? Date())
    }
  }
  
  var isStartDate: Bool = true
  
  var selectedStartDate: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    calendar.delegate = self
    print("\(selectedDate)!!!!!!!!!!")
    calendar.select(selectedDate ?? Date())
  }
  
  @IBAction func tapOk(_ sender: UIButton) {
    if selectedDate == nil {
      callMSGDialog(message: "날짜를 선택해주세요.")
    } else {
        delegate?.setDateString(dateString: dateString!)
      backPress()
    }
  }
  
  
  
  
  
}
extension SelectCalendarDateViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
  
  func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
    for d in calendar.selectedDates {
      calendar.deselect(d)
    }
    
    calendar.select(date)
    selectedDate = date.noon
  }
  
}
