//
//  Functions.swift
//  FOAV
//
//  Created by hoon Kim on 30/10/2019.
//  Copyright © 2019 hoon Kim. All rights reserved.
//

import Foundation

enum ImageType {
    case bottom
    case setting
}

func getImageURL(imageString: String, type: ImageType) -> URL {
    switch type {
    case .bottom:
        return URL(string: "\(imageString).png")!
    case .setting:
        return URL(string: "\(imageString).png")!
    }
}

// 배열 값을 알고 잇으면 배열 값으로 해당 값을 지울수 잇는 extension
extension Array where Element: Equatable {
    
    mutating func remove(_ element: Element) {
        _ = index(of: element).flatMap {
            self.remove(at: $0)
        }
    }
}
