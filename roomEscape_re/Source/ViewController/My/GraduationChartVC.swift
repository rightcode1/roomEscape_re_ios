//
//  GraduationChartVC.swift
//  roomEscape_re
//
//  Created by 이남기 on 2022/10/17.
//

import Foundation
import UIKit
import Charts

class GraduationChartVC:BaseViewController, goDetail{
    func go(area: String,area1: String) {
        let vc = UIStoryboard.init(name: "My", bundle: nil).instantiateViewController(withIdentifier: "GraduationDeatilVC") as! GraduationDeatilVC
        vc.area = area
        vc.area1 = area1
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    @IBOutlet var mainTableView: UITableView!
    @IBOutlet var mainPieView: PieChartView!
  @IBOutlet var touchChartView: UIView!
  @IBOutlet var noOverLapLabel: UILabel!
    @IBOutlet var overLapLabel: UILabel!
    @IBOutlet var AllCompany: UILabel!
  @IBOutlet var shadowVIew: UIView!{
    didSet{
      shadowVIew.layer.cornerRadius = 5
      shadowVIew.layer.shadowColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
      shadowVIew.layer.shadowOpacity = 1
      shadowVIew.layer.shadowOffset = CGSize(width: 0, height: 2)
      shadowVIew.layer.shadowRadius = 2
    }
  }
  
    var list : [Graduation] = []
    
    var areaList : [String] = ["서울", "경기", "충청", "경상", "전라", "강원/제주"]
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    override func viewDidLoad() {
        mainTableView.delegate = self
        mainTableView.dataSource = self
        initStatistics()
        initBoardList()
    }
  
  func initStatistics() {
      ApiService.request(router: UserApi.statistics, success: { (response: ApiResponse<StatisticsResponse>) in
          guard let value = response.value else {
              return
          }
          if value.statusCode == 200 {
            self.noOverLapLabel.text = "\(value.data.totalOverlapThemeReviewCount) / \(value.data.totalThemeCount)"
            self.overLapLabel.text = "\(value.data.totalReviewCount) / \(value.data.overlappingThemeCount)"
            self.AllCompany.text = "\(value.data.reviewedOverlapCompanyCount) / \(value.data.totalCompanyCount)"
            let percentage = Double(value.data.totalOverlapThemeReviewCount) / Double(value.data.totalThemeCount) * 100
            self.setChart(pieChartView: self.mainPieView,totalPer: percentage)
            self.touchChartView.rx.tapGesture().when(.recognized)
                .bind(onNext: { [weak self] _ in
                  let vc = UIStoryboard.init(name: "My", bundle: nil).instantiateViewController(withIdentifier: "GraduationDeatilVC") as! GraduationDeatilVC
                  vc.area = nil
                  self?.navigationController?.pushViewController(vc, animated: true)
                }).disposed(by: self.disposeBag)
          } else {
              self.dismissHUD()
          }
      }) { (error) in
          self.dismissHUD()
      }
  }
    func initBoardList() {
        self.showHUD()
        ApiService.request(router: UserApi.userGraduation, success: { (response: ApiResponse<GraduationListResponse>) in
            guard let value = response.value else {
                return
            }
            if value.statusCode == 200 {
                self.list.removeAll()
                self.list = value.list
                self.mainTableView.reloadData()
                self.dismissHUD()
            } else {
                self.dismissHUD()
            }
        }) { (error) in
            self.dismissHUD()
        }
    }
  func setChart(pieChartView: PieChartView ,totalPer: Double) {
        print(totalPer)
        
        let months = ["Jan", "Feb"]
        var unitsSold :[Double] = []
    
        unitsSold.append(100-totalPer)
        unitsSold.append(totalPer)
        
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<months.count {
            let dataEntry1 = ChartDataEntry(x: Double(i), y: unitsSold[i], data: months[i] as AnyObject)
            dataEntries.append(dataEntry1)
        }
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: "")
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        pieChartData.setValueTextColor(NSUIColor.clear)
        pieChartView.data = pieChartData
        pieChartView.legend.enabled = false
        pieChartView.holeRadiusPercent = 0.8
        pieChartView.isUserInteractionEnabled = false
        pieChartView.setExtraOffsets(left: -15, top: -15, right: -15, bottom: -15)
        var colors: [UIColor] = []
        colors.append(UIColor(red: 237, green: 237, blue: 237))
        colors.append(UIColor(red: 255, green: 204, blue: 35))
        pieChartDataSet.colors = colors
        
        let fontSize = UIFont.boldSystemFont(ofSize: 24)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center

        let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.paragraphStyle: paragraph]
        let attributedStr = NSMutableAttributedString(string: "전국\n\(round(totalPer*100)/100)%",attributes: attributes)


        attributedStr.addAttribute(.font, value: fontSize, range: ("전국\n\(round(totalPer*100)/100)%" as NSString).range(of: "전국"))
        
        pieChartView.centerAttributedText = attributedStr
        mainTableView.layoutTableHeaderView()
    }
}
extension GraduationChartVC:UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return areaList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dict = areaList[indexPath.row]
        let cell = mainTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PieTableViewCell
        cell.delegate = self
        cell.initdelegate(data: graduateArea(area: dict), index: indexPath,area: dict)
        
        return cell
    }
    
    func graduateArea(area:String) -> [Graduation]{
        var items : [Graduation] = []
        for count in 0..<list.count{
            if (area == "경기") && ((list[count].area == "경기") || (list[count].area == "인천")){
              items.append(list[count])
            }else if list[count].area1 == area{
                items.append(list[count])
            }else if (area == "강원/제주") && ((list[count].area == "강원") || (list[count].area == "제주")){
                items.append(list[count])
            }
        }
      var result: [Graduation] = []
      var others: [Graduation] = []

      for item in items {
          if item.area == "기타" {
              others.append(item)
          } else {
              result.append(item)
          }
      }

      result.append(contentsOf: others)

      return result
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch areaList[indexPath.row]{
        case "서울","경기":
            return ((tableView.bounds.size.width - 90) / 4 + 13) * 2
        default:
            return 130
        }
    }
    
}
