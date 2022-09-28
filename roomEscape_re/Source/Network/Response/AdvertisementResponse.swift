//
//  AdvertisementResponse.swift
//  roomEscape_re
//
//  Created by hoon Kim on 2022/02/22.
//

import Foundation

// MARK: - AdvertisementListResponse
struct AdvertisementListResponse: Codable {
  let statusCode: Int
  let message: String
  let list: [AdvertisementData]
}

// MARK: - AdvertisementData
struct AdvertisementData: Codable {
  let id: Int
  let title: String
  let sortCode: Int
  let url, thumbnail,endDate: String?
    let diff, location: String
  let image: String?
  let active: Bool
  let createdAt: String
}
