//
//  PieTableViewCell.swift
//  roomEscape_re
//
//  Created by 이남기 on 2022/11/23.
//

import Foundation
import Charts
import RxSwift

protocol goDetail{
  func go(area: String,area1: String)
}

class PieTableViewCell: UITableViewCell{
    @IBOutlet var backView: UIView!
    @IBOutlet var mainCollectionView: UICollectionView!
    @IBOutlet var chart: PieChartView!
    @IBOutlet var chartTouchView: UIView!
  
    var disposeBag: DisposeBag?
    var areaList : [Graduation] = []
    var delegate: goDetail?
    
    func initdelegate(data: [Graduation],index: IndexPath,area: String){
        shadow(view: self.backView, radius: 15, offset: CGSize(width: 0, height: 2))
        areaList = data
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        mainCollectionView.reloadData()
        
        let months = ["Jan", "Feb"]
        var unitsSold :[Double] = []
        var successPer: Double = 0.0
        var successCount: Int = 0
        var themeCount: Int = 0
        var smallArea = ""
        for count in 0..<data.count{
            successPer += data[count].successPer
            successCount += data[count].successCount
            themeCount += data[count].themeCount
          if (smallArea == ""){
            smallArea.append(data[count].area)
          }else{
            smallArea.append(",")
            smallArea.append(data[count].area)
          }
        }
        let totalPer = successPer/Double(data.count)
      
        unitsSold.append(100-totalPer)
        unitsSold.append(totalPer)
        
        setChart(dataPoints: months, values: unitsSold,pieChartView: chart)
        let fontSize = UIFont.boldSystemFont(ofSize: 16)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center

        let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.paragraphStyle: paragraph]
        let attributedStr = NSMutableAttributedString(string: "\(area)\n\(round(totalPer*100)/100)%\n\(successCount)/\(themeCount)",attributes: attributes)


        attributedStr.addAttribute(.font, value: fontSize, range: ("\(area)\n\(round(totalPer*100)/100)%\n\(successCount)/\(themeCount)" as NSString).range(of: area))
        
        chart.centerAttributedText = attributedStr
        print(smallArea)
      print(area)
      
       
      disposeBag = DisposeBag()
      chartTouchView.rx.tapGesture().when(.recognized)
          .bind(onNext: { [weak self] _ in
            self?.delegate?.go(area: smallArea,area1: area)
          }).disposed(by: disposeBag!)
    }
    func shadow(view: UIView, radius: CGFloat, offset: CGSize) {
      view.layer.cornerRadius = radius
      view.layer.shadowColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
      view.layer.shadowOpacity = 1
      view.layer.shadowOffset = offset
      view.layer.shadowRadius = 2
    }
    
}
extension PieTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return areaList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dict = areaList[indexPath.row]
        let cell = self.mainCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        guard let chart = cell.viewWithTag(1) as? PieChartView,
              let area = cell.viewWithTag(2) as? UILabel else {
            return cell
        }
        area.text = dict.area
        print(areaList)
        
        let months = ["Jan", "Feb"]
        var unitsSold :[Double] = []
        unitsSold.append(100-dict.successPer)
        unitsSold.append(dict.successPer)
        setChart(dataPoints: months, values: unitsSold,pieChartView: chart)
        chart.centerText = "\(round(dict.successPer*100)/100)%\n\(dict.successCount)/\(dict.themeCount)"
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width = mainCollectionView.bounds.size.width - 148
        return CGSize(width: self.mainCollectionView.bounds.size.width / 4 , height: self.mainCollectionView.bounds.size.width / 4 + 13)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.go(area: areaList[indexPath.row].area,area1: areaList[indexPath.row].area1)
    }
    
    func setChart(dataPoints: [String], values: [Double], pieChartView: PieChartView) {
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry1 = ChartDataEntry(x: Double(i), y: values[i], data: dataPoints[i] as AnyObject)
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
    }
}
