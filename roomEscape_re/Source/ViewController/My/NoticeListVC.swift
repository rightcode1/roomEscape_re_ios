//
//  NoticeListVC.swift
//  roomEscape_re
//
//  Created by hoon Kim on 2022/03/16.
//

import UIKit

class NoticeListVC: BaseViewController {
  @IBOutlet var tableView: UITableView!
  
  var boardList: [NoticeBoard] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    initBoardList()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.navigationBar.isHidden = false
  }
  
  func initBoardList() {
    self.showHUD()
    ApiService.request(router: NoticeBoardAPI.boardList(diff: "공지사항"), success: { (response: ApiResponse<NoticeBoardListResponse>) in
      guard let value = response.value else {
        return
      }
      if value.statusCode == 200 {
        self.boardList.removeAll()
        self.boardList = value.list
        self.tableView.reloadData()
        self.dismissHUD()
      } else {
        self.dismissHUD()
      }
    }) { (error) in
      self.dismissHUD()
    }
  }
  
  
}
extension NoticeListVC: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return boardList.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let dict = boardList[indexPath.row]

    (cell.viewWithTag(1) as! UILabel).text = dict.title
    (cell.viewWithTag(2) as! UILabel).text = dict.content

    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let vc = UIStoryboard.init(name: "My", bundle: nil).instantiateViewController(withIdentifier: "NoticeDetailVC") as! NoticeDetailVC
    let dict = boardList[indexPath.row]
    vc.titleString = dict.title
    vc.contentString = dict.content
    self.navigationController?.pushViewController(vc, animated: true)
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 74
  }

}

