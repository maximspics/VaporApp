//
//  Catalog.swift
//  
//
//  Created by Maxim Safronov on 08.12.2020.
//

import Foundation
import Vapor

typealias Product = Dictionary<String,Any>

class Catalog {
    let resulter = Results()
    let catalogDB: [Product] = [["id_product": 123,
                                 "product_name": "Ноутбук",
                                 "price": 45600,
                                 "product_description": "Мощный игровой ноутбук"],
                                ["id_product": 456,
                                 "product_name": "Мышка",
                                 "price": 1000,
                                 "product_description": "Мощная игровая мышка"]]
    
    struct CatalogGetParam: Content {
        var id: Int?
    }
    
    func doAction(action: String, queryString: URLQueryContainer?) -> String {
        switch action {
        case "list":
            return list(queryString)
        case "product":
            return product(queryString)
        default:
            return resulter.returnError(message: "Unknown method")
        }
    }
    
    func list(_ queryString: URLQueryContainer? = nil) -> String {
        var resultList: [Product] = []
        var good: Product
        
        for var product in catalogDB {
            // Внезапно в списке товаров не нужно описание :)
            product.removeValue(forKey: "product_description")
            good = product
            
            // Формируем массив с результатами
            resultList.append(good)
        }
        
        return resulter.returnArrayResult(resultList)
    }
    
    func productBy(_ productId: Int) -> [Product]? {
        // Ищем запрошенный товар
        let product = catalogDB.filter { product in
            if let pID = product["id_product"] as? Int,
                pID == productId {
                return true
            }
            
            return false
        }
        
        return product
    }
    
    func product(_ queryString: URLQueryContainer? = nil) -> String {
        guard let query = try? queryString?.get(CatalogGetParam.self),
            let productId = query.id else {
            return resulter.returnError(message: "Good not found")
        }
        
        // Проверяем наличие всех необходимых данных
        guard let product = self.productBy(productId),
            let firstProduct = product.first,
            let productName = firstProduct["product_name"],
            let prodcutPrice = firstProduct["price"],
            let productDescription = firstProduct["product_description"] else {
                return resulter.returnError(message: "Good not found")
        }
        
        // Собираем результирующий массив с описанием товара
        let result: Product = ["product_name": productName,
                               "product_price": prodcutPrice,
                               "product_description": productDescription
        ]
        
        // Возвращаем JSON
        return resulter.returnResult(result)
        
    }
}

