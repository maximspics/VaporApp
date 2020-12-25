//
//  User.swift
//  
//
//  Created by Maxim Safronov on 21.12.2020.
//

import Vapor
import FluentSQLiteDriver

final class User: Model, Content  {
    // Name of the table or collection.
    static let schema = "users"
    
    // Unique identifier for this User.
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "userId")
    var userId: Int?
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "password")
    var password: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "first_name")
    var firstName: String
    
    @OptionalField(key: "last_name")
    var lastName: String?
    
    // Creates a new, empty User.
    init() { }
    
    // Creates a new User with all properties set.
    init(id: UUID? = nil, userId: Int? = nil, username: String, password: String, firstName: String, lastName: String, email: String) {
        self.id = id
        self.userId = userId
        self.username = username
        self.password = password
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
    }
}

struct CreateUser: Migration {
    // Prepares the database for storing User models.
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        let result = database.schema("users")
            .id()
            .field("userId", .int)
            .field("username", .string, .required)
            .field("password", .string, .required)
            .field("email", .string, .required)
            .field("first_name", .string, .required)
            .field("last_name", .string)
            .create()
        let _ = User(userId: 1, username: "test", password: "test",
                         firstName: "John", lastName: "Doe",
                         email: "test@mail.ru")
            .save(on: database)
        return result
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users").delete()
    }
}

