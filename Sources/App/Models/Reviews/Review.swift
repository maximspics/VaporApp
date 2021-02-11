//
//  Review.swift
//  
//
//  Created by Maxim Safronov on 27.12.2020.
//

import Vapor
import FluentSQLiteDriver

final class Review: Model, Content {
    static let schema = "reviews"
        
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "id_review")
    var idReview: Int

    @Field(key: "id_product")
    var idProduct: Int
    
    @Field(key: "user_name")
    var userName: String
    
    @Field(key: "user_email")
    var userEmail: String
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "show")
    var show: Bool
    
    @Field(key: "description")
    var description: String
    
    init() { }
    
    init(id: Int? = nil, idProduct: Int, userName: String, userEmail: String, title: String, show: Bool, description: String) {
        self.idReview = id ?? -1
        self.idProduct = idProduct
        self.userName = userName
        self.userEmail = userEmail
        self.title = title
        self.show = show
        self.description = description
    }
}

struct CreateReview: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        let result = database.schema("reviews")
            .id()
            .field("id_review", .int, .required)
            .field("id_product", .int, .required)
            .field("user_name", .string, .required)
            .field("user_email", .string, .required)
            .field("title", .string, .required)
            .field("show", .bool, .required)
            .field("description", .string, .required)
            .create()
        
        let _ = Review(id: 1, idProduct: 1, userName: "Даша", userEmail: "dasha@mail.ru",
                       title: "Отзыв о телефоне", show: true, description: "Отличный телефон!")
            .save(on: database)
        
        let _ = Review(id: 2, idProduct: 2, userName: "Semen Lui", userEmail: "semen@mail.ru",
                              title: "Отзыв о чехле", show: true, description: "Быстро запачкался!")
            .save(on: database)
        
        
        return result
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("reviews").delete()
    }
}
