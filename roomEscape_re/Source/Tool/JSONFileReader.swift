//
//  JSONFileReader.swift
//  BARO
//
//  Created by ldong on 2018. 1. 29..
//  Copyright © 2018년 weplanet. All rights reserved.
//

import Foundation

class JSONFileReader {
    
    class func getJSONNamed(_ filename: String) -> NSDictionary? {
        
        let myBundle = Bundle.init(for: self)
        if let path = myBundle.path(forResource: filename, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: NSData.ReadingOptions.mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options:.mutableContainers)
                let dictionary = jsonResult as? NSDictionary
                return dictionary ?? nil
                
            } catch let error as NSError {
                debugPrint(error.localizedDescription)
                return nil
            }
        } else {
            debugPrint("Invalid filename/path.")
            return nil
        }
    }
    
}
