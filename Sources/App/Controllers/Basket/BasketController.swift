//
//  BasketController.swift
//  
//
//  Created by Maxim Safronov on 08.12.2020.
//

import Fluent
import FluentSQLiteDriver
import Vapor

class BasketController {
    
    var results = Results()
    
    func getBasketByUserIdAndProductId(userId: Int, productId: Int, _ req: Request) -> EventLoopFuture<Basket?> {
        return Basket.query(on: req.db)
            .filter(\.$userId, .equal, userId)
            .filter(\.$idProduct, .equal, productId)
            .first()
    }
    
    func getBasket(_ req: Request) throws -> EventLoopFuture<String> {
        guard let basket = try? req.content.decode(BasketRequest.self),
              let userId = basket.userId else {
            throw results.error(message: "Пользователь не найден...", req) as! Error
        }
        
        return Basket.query(on: req.db)
            .filter(\.$userId, .equal, userId)
            .all().map { items -> [[String: Any]] in
                return items.map { item -> [String: Any] in
                    print(item)
                    if let idProduct = item.$idProduct.value,
                        let productName = item.$productName.value,
                        let price = item.$price.value,
                        let quantity = item.$quantity.value {
                        
                        return ["id_product": idProduct,
                                "product_name": productName,
                                "price": price,
                                "quantity": quantity
                        ]
                    } else {
                        return [:]
                    }
                    
                }
        }.flatMap { basket -> EventLoopFuture<String> in
            if basket.count > 0 {
                var amount: Int = 0
                var countGoods: Int = 0
                
                for item in basket {
                    if let price = item["price"] as? Int,
                        let quantity = item["quantity"] as? Int {
                        
                        countGoods += quantity
                        amount += (price * quantity)
                    }
                }
                
                let result: [String: Any] = ["amount": amount,
                                             "countGoods": countGoods,
                                             "contents": basket]
                
                return self.results.returnResult(result, req)
                
            } else {
                let result: [String: Any] = ["amount": 0,
                                             "countGoods": 0,
                                             "contents": []]
                
                return self.results.returnResult(result, req)
            }
        }
    }
    
    func addToBasket(_ req: Request) -> EventLoopFuture<String> {
        guard let basket = try? req.content.decode(BasketRequest.self),
            let userId = basket.userId,
            let productId = basket.productId,
            let quantity = basket.quantity else {
            return results.error(message: "Невозможно добавить в корзину...", req)
        }
        return getBasketByUserIdAndProductId(userId: userId, productId: productId, req).flatMap { basket -> EventLoopFuture<String> in
            if let basket = basket {
                    basket.quantity = (basket.$quantity.value ?? 0) + quantity;
                    
                    return basket.update(on: req.db).flatMapAlways { result -> EventLoopFuture<String> in
                        switch result {
                        case .success(_):
                            let result: Dictionary<String, Any> =
                                [
                                    "result": 1,
                                    "userMessage": "Товар успешно добавлен в корзину!"
                                ]
                            return self.results.returnResult(result, req)
                        case .failure(_):
                            return self.results.error(message: "Ошибка добавления товара в корзину!", req)
                        }
                    }
                } else {
                    return self.addToBasketNewProd(req)
                }
        }
    }
    
    // MARK: Добавляем продукт в корзину
    func addToBasketNewProd(_ req: Request) -> EventLoopFuture<String> {
        guard let query = try? req.content.decode(BasketRequest.self),
            let userId = query.userId,
            let productId = query.productId,
            let quantity = query.quantity else {
            return results.error(message: "Невозможно добавить в корзину...", req)
        }
        
        return GoodsController().getProductById(productId, req).map { good -> EventLoopFuture<String> in
            if let good = good,
                let price = good.$price.value,
                let productName = good.$productName.value {
                
                return Basket(idProduct: productId, userId: userId,
                        productName: productName, price: price,
                        quantity: quantity).save(on: req.db).flatMapAlways { result -> EventLoopFuture<String> in
                            switch result {
                            case .success():
                                let result: Dictionary<String, Any> =
                                    [
                                        "result": 1,
                                        "userMessage": "Товар успешно добавлен в корзину!"
                                    ]
                                return self.results.returnResult(result, req)
                            case .failure(_):
                                return self.results.error(message: "Невозможно добавить товар в корзину!", req)
                            }
                }
            } else {
                return self.results.error(message: "Товар не найден!", req)
            }
        }.flatMap { basketResult -> EventLoopFuture<String> in
            return basketResult
        }
    }
    
    func clearBasket(_ req: Request) throws -> EventLoopFuture<String> {
        guard let query = try? req.content.decode(BasketRequest.self),
            let userId = query.userId else {
            return results.error(message: "Wrong parameter count", req)
        }
        
        return Basket.query(on: req.db)
            .filter(\.$userId, .equal, userId)
            .all().flatMap { baskets -> EventLoopFuture<String> in
                baskets.forEach { basket in
                    let _ = basket.delete(on: req.db)
                }
                let result: Dictionary<String, Any> =
                    [
                        "result": 1,
                        "userMessage": "Корзина успешно очищена!"
                    ]
                return self.results.returnResult(result, req)
        }
    }
    
    func removeFromBasket(_ req: Request) throws -> EventLoopFuture<String> {
        guard let query = try? req.content.decode(BasketRequest.self),
            let userId = query.userId,
            let productId = query.productId else {
                return results.error(message: "Wrong parameter count", req)
        }
        
        // Ищем запись по продукту
        return Basket.query(on: req.db)
            .filter(\.$userId,.equal,userId)
            .filter(\.$idProduct,.equal,productId).first().map { product -> EventLoopFuture<String> in
                if let product = product {
                    return product.delete(on: req.db).flatMapAlways { result -> EventLoopFuture<String> in
                        switch result {
                        case .success():
                            let result: Dictionary<String, Any> =
                                [
                                    "result": 1,
                                    "userMessage": "Товар удален из корзины!"
                                ]
                            return self.results.returnResult(result, req)
                        case .failure(_):
                            return self.results.error(message: "Basket delete error", req)
                        }
                    }
                } else {
                    return self.results.error(message: "Basket delete error", req)
                }
                
        }.flatMap { result -> EventLoopFuture<String> in
            return result
        }
    }

    // MARK: Оплата карзины
    func payOrder(_ req: Request) throws -> EventLoopFuture<String> {
        guard let query = try? req.content.decode(BasketRequest.self),
            let userId = query.userId,
            let paySumm = query.paySumm else {
                return results.error(message: "Wrong parameter count", req)
        }
                
        // Получаем корзину пользователя
        return Basket.query(on: req.db)
            .filter(\.$userId, .equal, userId)
            .all().map { items -> EventLoopFuture<String> in
                var totalPrice: Int = 0
                
                if items.count > 0 {
                    for item in items  {
                        if let price = item.$price.value,
                            let quantity = item.$quantity.value {
                            totalPrice += (price * quantity)
                        }
                    }
                }
                
                if totalPrice > 0 && paySumm == totalPrice {
                    let result: Dictionary<String, Any> =
                        [
                            "result": 1,
                            "message": "Товар оплачен. Сумма \(totalPrice)"
                        ]
                    return self.results.returnResult(result, req)
                } else {
                    if totalPrice == 0 {
                        return self.results.error(message: "Ошибка подсчета суммы товаров", req)
                    } else if totalPrice != paySumm {
                        return self.results.error(message: "Недостаточно средств", req)
                    } else {
                        return self.results.error(message: "Что-то пошло не так...", req)
                    }
                }
        }.flatMap { result -> EventLoopFuture<String> in
            return result
        }

    }
}
    
