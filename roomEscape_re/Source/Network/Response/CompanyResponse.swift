//
//  CompanyResponse.swift
//  roomEscape_re
//
//  Created by hoon Kim on 2022/01/28.
//

import Foundation

// MARK: - CompanyListResponse
struct CompanyListResponse: Codable {
  let statusCode: Int
  let message: String
  let list: [CompanyListData]
}

// MARK: - CompanyListResponse
struct CompanyDefaultListResponse: Codable {
  let statusCode: Int
  let message: String
  let list: CompanyRows
}

struct CompanyRows: Codable {
  let count: Int
  let rows: [CompanyListData]
}

// MARK: - CompanyListData
struct CompanyListData: Codable {
  let id: Int
  let title : String
  var isWish: Bool
  var wishCount: Int
  let averageRate: Double
  let reviewCount: Int
  let themeThumbnails: [String]
  let latitude,longitude,thumbnail: String?
}

struct CompanyGradutaionListResponse: Codable {
  let statusCode: Int
  let message: String
  let list: [GraduationCompanyListData]
}
struct GraduationCompanyListData: Codable {
  let id: Int
  let title : String
  var wishCount: Int
  let averageRate: Double
  let reviewCount: Int
  let themes: [Themes]
  let thumbnail: String?
}

struct Themes: Codable {
  let id: Int
  let title : String
  var isSuccess: Bool
  
}
struct CompanyWishListResponse: Codable {
  let statusCode: Int
  let message: String
  let list: [WishCompanyListData]
}

struct WishCompanyListData: Codable {
  let id: Int
  let title : String
  var isWish: Bool
  var wishCount: Int
  let averageRate: Double
  let reviewCount: Int
  let latitude,longitude,thumbnail: String?
}


// MARK: - CompanyDetailResponse
struct CompanyDetailResponse: Codable {
  let statusCode: Int
  let message: String
  let data: CompanyDetailData
}

// MARK: - CompanyDetailData
struct CompanyDetailData: Codable {
  let id: Int
  let title, intro, address, latitude: String
  let longitude: String
  let homepage: String
  let wishCount: Int
  let isWish: Bool
  let thumbnail: String?
  let distance: Int
  let tel: String
    let reviewCount : Int
    let averageRate: Double
  let companyImages: [Image]
}
