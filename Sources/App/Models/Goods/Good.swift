//
//  Good.swift
//  
//
//  Created by Maxim Safronov on 27.12.2020.
//

import Vapor
import FluentSQLiteDriver

final class Good: Model, Content {
    static let schema = "goods"
        
    @ID(key: .id)
    var id: UUID?

    @Field(key: "id_product")
    var idProduct: Int
    
    @Field(key: "product_name")
    var productName: String
    
    @Field(key: "product_image")
    var productImage: String?
    
    @Field(key: "price")
    var price: Int
    
    @Field(key: "product_description")
    var productDescription: String
    
    init() { }
    
    init(id: Int? = nil, productName: String, price: Int, productDescription: String, productImage: String?) {
        self.idProduct = id ?? -1
        self.productName = productName
        self.productDescription = productDescription
        self.price = price
        self.productImage = productImage
    }
}
struct CreateGood: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        let result = database.schema("goods")
            .id()
            .field("id_product", .int, .required)
            .field("product_name", .string, .required)
            .field("product_image", .string)
            .field("price", .int, .required)
            .field("product_description", .string, .required)
            .create()
        
        let cat1 = Good(id: 1, productName: "Iphone X",
                               price: 54990,
                               productDescription: "Оригинальный белый Iphone X на 64 гб",
                               productImage: "https://images.macrumors.com/t/ADB6OTXQIFlyQq5fXXeqFHTGHgc=/1600x/http://images.macrumors.com/article-new/2017/10/iphone-x-silver.jpg")
                               
            
        let cat2 = Good(id: 2, productName: "Чехол для Iphone X",
                               price: 2500,
                               productDescription: "Чехол Apple iPhone X Leather Folio (MQRY2ZM/A), Taupe",
                               productImage: "https://topcomputer.ru/upload/resize_cache/images/97/1024_768_140cd750bba9870f18aada2478b24840a/97d3f4f7bbed70b89ebf52fabecbc601.png")
                               
            
        let _ = cat1.save(on: database)
        let _ = cat2.save(on: database)
        
        return result
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("goods").delete()
    }
}
