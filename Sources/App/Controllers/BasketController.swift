//
//  BasketController.swift
//  
//
//  Created by Maxim Safronov on 08.12.2020.
//

import Foundation
import Vapor

typealias BasketStruct = Dictionary<String,Any>
typealias BasketItem = Dictionary<String,Any>
typealias PayResult = Dictionary<String,Any>

class Basket {
    let results = Results()
    var basket: [BasketItem] = [
        ["id_product": 456,
         "price": 2500,
         "product_name": "Мышка",
         "quantity": 2
        ],
        ["id_product": 789,
         "price": 38900,
         "product_name": "Смартфон",
         "quantity": 1
        ]
    ]
    
    struct BasketGetParam: Content {
        var sessionId: Int?
    }
    
    struct BasketAddParam: Content {
        var sessionId: Int?
        var productId: Int?
        var quantity: Int?
    }
    
    struct BasketRemoveParam: Content {
        var sessionId: Int?
        var productId: Int?
    }
    
    struct BasketPayParam: Content {
        var sessionId: Int?
        var paySumm: Int?
    }
    
    func doAction(action: String, queryString: URLQueryContainer?) -> String {
        switch action {
        case "get":
            return getBasket(queryString)
        case "add":
            return addToBasket(queryString)
        case "remove":
            return removeFromBasket(queryString)
        case "pay":
            return payOrder(queryString)
        default:
            return results.returnError(message: "Unknown method")
        }
    }
    
    func getBasket(_ queryString: URLQueryContainer? = nil) -> String {
        guard let query = try? queryString?.get(BasketGetParam.self),
              let _ = query.sessionId else {
            return results.returnError(message: "Session not found")
        }
        
        if !basket.isEmpty {
            var amount: Int = 0
            
            basket.forEach { (product: Product) in
                if let count = product["quantity"] as? Int {
                    amount += count
                }
            }
            
            let result: BasketStruct = ["amount": amount,
                                        "countGoods": basket.count,
                                        "contents": basket
            ]
            
            return results.returnResult(result)
            
        } else {
            return results.returnError(message: "Basket empty")
        }
    }
    
    func addToBasket(_ queryString: URLQueryContainer? = nil) -> String {
        guard let query = try? queryString?.get(BasketAddParam.self),
              let _ = query.sessionId,
              let productId = query.productId,
              let quantity = query.quantity else {
            return results.returnError(message: "Wrong parameter count")
        }
        
        if let product = Catalog().productBy(productId),
           let firstProduct = product.first,
           let productName = firstProduct["product_name"],
           let productPrice = firstProduct["price"] {
            
            let product: BasketItem = ["id_product": productId,
                                       "price": productPrice,
                                       "product_name": productName,
                                       "quantity":quantity
            ]
            
            basket.append(product)
            
            return results.returnResult()
        } else {
            return results.returnError(message: "Can't find product with id: \(productId)")
        }
    }
    
    func removeFromBasket(_ queryString: URLQueryContainer? = nil) -> String {
        guard let query = try? queryString?.get(BasketRemoveParam.self),
              let _ = query.sessionId,
              let productId = query.productId else {
            return results.returnError(message: "Wrong parameter count")
        }
        
        if !basket.isEmpty {
            for i in 0..<basket.count {
                if let pID = basket[i]["id_product"] as? Int,
                   pID == productId {
                    basket.remove(at: i)
                    return results.returnResult()
                }
            }
            
            return results.returnError(message: "Product with id: \(productId) not found in basket")
        } else {
            return results.returnError(message: "Basket is empty")
        }
    }
    
    func payOrder(_ queryString: URLQueryContainer? = nil) -> String {
        guard let query = try? queryString?.get(BasketPayParam.self),
              let _ = query.sessionId,
              let paySumm = query.paySumm else {
            return results.returnError(message: "Wrong parameter count")
        }
        
        if !basket.isEmpty {
            var totalPrice: Int = 0
            
            basket.forEach { (product: Product) in
                if let count = product["quantity"] as? Int,
                   let price = product["price"] as? Int {
                    totalPrice += (price * count)
                    print(totalPrice)
                }
            }
            
            if totalPrice > 0 && paySumm == totalPrice {
                let result: PayResult = ["result": 1, "message": "Товар на сумму \(totalPrice) рублей оплачен!"]
                
                return results.returnResult(result)
            } else {
                guard totalPrice > 0 else {
                    return results.returnError(message: "Ошибка подсчета суммы товаров в корзине")
                }
                
                guard paySumm != totalPrice else {
                    return results.returnError(message: "Не хватает денег")
                }
                
                return results.returnError(message: "Что-то пошло не так.")
            }
        } else {
            return results.returnError(message: "Basket is empty")
        }
        
    }
}
