//
//  VersionResponse.swift
//  kospiKorea
//
//  Created by hoonKim on 2020/05/19.
//  Copyright © 2020 hoon Kim. All rights reserved.
//

import Foundation

struct VersionResponse: Codable {
  let statusCode: Int
  let message: String 
  let data: Version
}

struct Version: Codable {
  let ios: Int
  let android: Int
}
