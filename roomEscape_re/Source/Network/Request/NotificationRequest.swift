//
//  NotificationRequest.swift
//  ppuryo
//
//  Created by hoonKim on 2021/05/27.
//

import Foundation

struct SettingNotificationRequest: Codable {
  let eventPush: String
  let waterPush: String
  let feedPush: String
}

struct NotificationRequest: Codable {
    var notificationToken: String
}
