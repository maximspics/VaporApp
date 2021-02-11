//
//  GoodsController.swift
//  
//
//  Created by Maxim Safronov on 08.12.2020.
//

import Fluent
import FluentSQLiteDriver
import Vapor

class GoodsController {

    var results = Results()
    
    func getProductById(_ productId: Int, _ req: Request) -> EventLoopFuture<Good?> {
        return Good.query(on: req.db)
            .filter(\.$idProduct, .equal, productId)
            .limit(1)
            .first()
    }
    
    func list(_ req: Request) -> EventLoopFuture<String> {
        return Good.query(on: req.db)
            .all().map { good -> [[String: Any]] in
                return good.map { item -> [String: Any] in
                    if let productId = item.$idProduct.value,
                        let productName = item.$productName.value,
                        let productDescription = item.$productDescription.value,
                        let price = item.$price.value {
                        
                        return [
                            "product_id": productId,
                            "product_name": productName,
                            "product_image": (item.$productImage.value ?? "") ?? "",
                            "product_description": productDescription,
                            "product_price": price,
                            "result": 1
                        ]
                    } else {
                        return [:]
                    }
                }
        }.flatMap { result -> EventLoopFuture<String> in
            return self.results.returnArrayResult(result, req)
        }
    }
    
    func product(_ req: Request) throws -> EventLoopFuture<String> {
        guard let good = try? req.content.decode(GoodRequest.self),
            let productId = good.id else
        {
            throw Abort(.badRequest)
        }
        
        return getProductById(productId, req).flatMap { product -> EventLoopFuture<String> in
            if let product = product {
                let result: Dictionary<String, Any> =
                    [
                        "product_id": product.idProduct,
                        "product_name": product.productName,
                        "product_price": product.price,
                        "product_description": product.productDescription,
                        "product_image": ((product.productImage ?? ""))
                    ]
                return self.results.returnResult(result, req)
            } else {
                return self.results.error(message: "Товар не найден!", req)
            }
        }
    }
}

