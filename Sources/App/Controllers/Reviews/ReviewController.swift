//
//  File.swift
//  
//
//  Created by Maxim Safronov on 27.12.2020.
//

import Foundation
import Vapor

class ReviewController {
    
    var results: Results!
    
    func getReviewById(reviewId: Int, _ req: Request) -> EventLoopFuture<Review?> {
        return Review.query(on: req.db)
            .filter(\.$reviewId, .equal, reviewId)
            .limit(1)
            .first()
    }
    
    func add(_ req: Request) throws -> EventLoopFuture<String> {
        guard let query = try? req.query.get(ReviewRequest.self),
            let productId = query.productId,
            let userName = query.user_name, let userEmail = query.user_email,
            let title = query.title, let descritpion = query.description else {
            throw Abort(.badRequest, reason: "Ошибка получения данных...")
        }
        
        return Review.query(on: req.db).max(\.$reviewId).flatMapAlways { result -> EventLoopFuture<String> in
            switch result {
            case let .success(maxId):
                if let maxId = maxId {
                    return Review(id: (maxId + 1), idProduct: productId,
                                      userName: userName, userEmail: userEmail,
                                      title: title, show: false, reviewDescription: descritpion)
                        .save(on: req.db).flatMapAlways { result -> EventLoopFuture<String> in
                            switch result {
                            case .success():
                                return self.results.returnResult(["userMessage": "Комментарий добавлен!"], req)
                            case .failure(_):
                                return self.results.error(message: "Комментарий не добавлен!", req)
                            }
                    }
                } else {
                    return self.results.error(message: "Комментарий не добавлен!", req)
                }
                
            case .failure(_):
                return self.results.error(message: "Комментарий не добавлен!", req)
            }
        }
    }
    
    func approve(_ req: Request) throws -> EventLoopFuture<String> {
        guard let query = try? req.query.get(ReviewRequest.self),
            let reviewId = query.reviewId else {
            throw Abort(.badRequest, reason: "Ошибка получения данных...")
        }
        
        return getReviewById(reviewId: reviewId, req).map { review -> EventLoopFuture<String> in
            if let review = review {
                review.show = true
                
                return review.update(on: req.db).flatMapAlways { result -> EventLoopFuture<String> in
                    switch result {
                    case .success(_):
                        let result: [Dictionary<String, Any>] =
                            [
                                [
                                    "result": 1,
                                    "userMessage": "Отзыв одобрен модератором!"
                                ],
                                [
                                    "result": 1,
                                    "userMessage": "Отзыв одобрен модератором!"
                                ]
                            ]
                        return self.results.returnArrayResult(result, req)
                    case .failure(_):
                        return self.results.error(message: "Approve error", req)
                    }
                }
            } else {
                return self.results.error(message: "Отзыв не найден!", req)
            }
        }.flatMap { result -> EventLoopFuture<String> in
            return result
        }
    }
    
    func remove(_ req: Request) throws -> EventLoopFuture<String> {
        guard let query = try? req.query.get(ReviewRequest.self),
            let reviewId = query.reviewId else {
            throw Abort(.badRequest, reason: "Ошибка получения данных...")
        }
        
        if reviewId == 3 {
            let result: Dictionary<String, Any> =
                [
                    "result": 1,
                    "userMessage": ""
                ]
            return results.returnResult(result, req)
        }
        
        return getReviewById(reviewId: reviewId, req).map { review -> EventLoopFuture<String> in
            if let review = review {
                return review.delete(on: req.db).flatMapAlways { resultDelete -> EventLoopFuture<String> in
                    switch resultDelete {
                    case .success():
                        let result: Dictionary<String, Any> =
                            [
                                "result": 1,
                                "userMessage": "Отзыв успешно удален!"
                            ]
                        return self.results.returnResult(result, req)
                    case .failure(_):
                        return self.results.error(message: "Ошибка удаления!", req)
                    }
                }
            } else {
                return self.results.error(message: "Отзыв не найден", req)
            }
        }.flatMap { result -> EventLoopFuture<String> in
            return result
        }
    }
    
    func list(_ req: Request) throws -> EventLoopFuture<String> {
        guard let query = try? req.query.get(GetReviewList.self),
            let productId = query.productId else {
            throw Abort(.badRequest, reason: "Ошибка получения данных...")
        }
        
        return Review.query(on: req.db)
            .filter(\.$idProduct, .equal, productId)
            .all().map { list -> [[String: Any]] in
                list.map { item -> [String: Any] in
                    if let reviewId = item.$reviewId.value,
                        let productId = item.$idProduct.value,
                        let title = item.$title.value,
                        let reviewDescription = item.$reviewDescription.value,
                        let show = item.$show.value,
                        let userName = item.$userName.value,
                        let userEmail = item.$userEmail.value {
                        
                        return ["id": reviewId,
                                "id_product": productId,
                                "title": title,
                                "description": reviewDescription,
                                "show": show,
                                "user_name": userName,
                                "user_email": userEmail
                        ]
                    } else {
                        return [:]
                    }
                }
        }.flatMap { result -> EventLoopFuture<String> in
            if result.count > 0 {
                
                return self.results.returnArrayResult(result, req)
            } else {
                return self.results.error(message: "Отзыв не найден!", req)
            }
        }
    }
}
