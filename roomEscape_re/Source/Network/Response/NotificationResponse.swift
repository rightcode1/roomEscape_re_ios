//
//  NotificationResponse.swift
//  ppuryo
//
//  Created by hoonKim on 2021/05/27.
//

import Foundation

struct NotificationInfoResponse: Codable {
    let statusCode: Int
    let message: String
    let data: NotificationInfo?
}

struct NotificationInfo: Codable {
    let notificationToken: String
    let active: Bool
}
