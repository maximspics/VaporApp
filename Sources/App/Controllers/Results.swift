//
//  Results.swift
//  
//
//  Created by Maxim Safronov on 08.12.2020.
//

import Foundation

class Results {
    func returnError(message: String) -> String {
        return "{\"result\": 0, \"error\": \"\(message)\"}"
    }
    
    func returnArrayResult(_ res: [Dictionary<String,Any>]? = nil) -> String {
        if let res = res {
            if let jsonData = try? JSONSerialization.data(withJSONObject: res, options: [.withoutEscapingSlashes, .prettyPrinted]),
                let jsonString = String(data: jsonData, encoding: .utf8)
            {
                return jsonString
            } else {
                return returnError(message: "unknown error")
            }
        } else {
            return " {\"result\": 1} "
        }
    }
    
    func returnResult(_ res: Dictionary<String,Any>? = nil) -> String {
        if var res = res {
            res["result"] = 1
            
            if let jsonData = try? JSONSerialization.data(withJSONObject: res, options: [.withoutEscapingSlashes, .prettyPrinted]),
                let jsonString = String(data: jsonData, encoding: .utf8)
            {
                return jsonString
            } else {
                return returnError(message: "unknown error")
            }
        } else {
            return " {\"result\": 1} "
        }
    }
}
