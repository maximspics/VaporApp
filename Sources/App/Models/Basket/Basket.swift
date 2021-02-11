//
//  Basket.swift
//  
//
//  Created by Maxim Safronov on 25.12.2020.
//

import Vapor
import FluentSQLiteDriver

final class Basket: Model, Content  {
    // Name of the table or collection.
    static let schema = "baskets"
    
    // Unique identifier for this Basket.
    @ID(key: .id)
    var id: UUID?

    @Field(key: "id_product")
    var idProduct: Int
    
    @Field(key: "user_id")
    var userId: Int
    
    @Field(key: "product_name")
    var productName: String
        
    @Field(key: "price")
    var price: Int
    
    @Field(key: "quantity")
    var quantity: Int
    
    // Creates a new, empty Basket.
    init() { }
    
    // Creates a new Basket with all properties set.
    init(id: UUID? = nil, idProduct: Int, userId: Int, productName: String, price: Int, quantity: Int) {
        self.id = id
        self.idProduct = idProduct
        self.userId = userId
        self.productName = productName
        self.price = price
        self.quantity = quantity
    }
}

struct CreateBasket: Migration {
    // Prepares the database for storing Basket models.
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        let result = database.schema("baskets")
            .id()
            .field("id_product", .int, .required)
            .field("user_id", .int, .required)
            .field("product_name", .string, .required)
            .field("price", .int, .required)
            .field("quantity", .int, .required)
            .create()
        
        return result
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("baskets").delete()
    }
}

