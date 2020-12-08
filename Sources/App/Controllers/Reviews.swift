//
//  Reviews.swift
//  
//
//  Created by Maxim Safronov on 08.12.2020.
//

import Foundation
import Vapor

typealias Review = Dictionary<String,Any>

class Reviews {
    let resulter = Results()
    
    struct ReviewListParam: Content {
        var productId: Int?
    }
    
    struct ReviewAddParam: Content {
        var productId: Int?
        var user_name, user_email, title, description: String?
    }
    
    struct ReviewChangeParam: Content {
        var reviewId: Int?
    }
    
    var reviewDB: [Review] = [
        ["id_product": 123,
         "id": 1,
         "user_name": "Ivan",
         "user_email": "s@ivanov.com",
         "title": "Review #1",
         "show": true,
         "description": "Review #1 for product with id 123"],
        ["id_product": 123,
         "id": 2,
         "user_name": "Petr",
         "user_email": "p@ivanov.com",
         "title": "Review #2",
         "show": false,
         "description": "Review #2 for product with id 123"]
    ]
    
    func doAction(action: String, queryString: URLQueryContainer?) -> String {
        switch action {
        case "list":
            return list(queryString)
        case "add":
            return add(queryString)
        case "approve":
            return approve(queryString)
        case "remove":
            return remove(queryString)
        default:
            return resulter.returnError(message: "Unknown method")
        }
    }
    
    func add(_ queryString: URLQueryContainer?) -> String {
        guard let query = try? queryString?.get(ReviewAddParam.self),
            let productId = query.productId,
            let userName = query.user_name, let userEmail = query.user_email,
            let title = query.title, let descritpion = query.description
            else {
                return resulter.returnError(message: "Wrong parameter count")
        }
        
        let newReviewId = (reviewDB.count + 1)
        
        // Добавляем отзыв
        reviewDB.append([
            "id_product": productId,
            "id": newReviewId,
            "user_name": userName,
            "user_email": userEmail,
            "title": title,
            "description": descritpion,
            "show": false
        ])
        
        let result: Review = ["result": 1,
                              "userMessage": "Отзыв №\(newReviewId) был передан на модерацию"
        ]
        
        return resulter.returnResult(result)
    }
    
    func approve(_ queryString: URLQueryContainer?) -> String {
        guard let query = try? queryString?.get(ReviewChangeParam.self),
            let reviewId = query.reviewId
            else {
                return resulter.returnError(message: "You must specify review id")
        }
        
        if reviewDB.count > 0  {
            for i in 0..<reviewDB.count {
                if let rId = reviewDB[i]["id"] as? Int,
                    rId == reviewId {
                    reviewDB[i]["show"] = true
                    return resulter.returnResult()
                }
            }
            
            return resulter.returnError(message: "Review with id: \(reviewId) not found")
        } else {
            return resulter.returnError(message: "Reviews is empty")
        }
    }
    
    func remove(_ queryString: URLQueryContainer?) -> String {
        guard let query = try? queryString?.get(ReviewChangeParam.self),
            let reviewId = query.reviewId
            else {
                return resulter.returnError(message: "You must specify review id")
        }
        
        if reviewDB.count > 0  {
            for i in 0..<reviewDB.count {
                if let rId = reviewDB[i]["id"] as? Int,
                    rId == reviewId {
                    reviewDB.remove(at: i)
                    return resulter.returnResult()
                }
            }
            
            return resulter.returnError(message: "Review with id: \(reviewId) not found")
        } else {
            return resulter.returnError(message: "Reviews is empty")
        }
    }
    
    
    func list(_ queryString: URLQueryContainer?) -> String {
        guard let query = try? queryString?.get(ReviewListParam.self),
            let productId = query.productId
            else {
                return resulter.returnError(message: "You must specify product id")
        }
        
        // Ищем список отзывов к запрошенному товару
        let reviewsForPdocut = reviewDB.filter { review in
            if let pId = review["id_product"] as? Int, pId == productId,
                let state = review["show"] as? Bool, state == true {
                return true
            }
            
            return false
        }
        
        if reviewsForPdocut.count > 0 {
            return resulter.returnArrayResult(reviewsForPdocut)
        }
        
        return resulter.returnError(message: "Reviews not found")
    }
}
