//
//  User.swift
//  
//
//  Created by Maxim Safronov on 21.12.2020.
//

import Vapor
import FluentSQLiteDriver

final class User: Model, Content {
    // Name of the table or collection.
    static let schema = "users"
    
    // Unique identifier for this User.
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "userId")
    var userId: Int?
    
    @Field(key: "email")
    var email: String?
    
    @Field(key: "password")
    var password: String?
    
    @Field(key: "first_name")
    var firstName: String?
    
    @OptionalField(key: "last_name")
    var lastName: String?
    
    // Creates a new, empty User.
    init() { }
    
    // Creates a new User with all properties set.
    init(id: UUID? = nil, userId: Int? = nil, email: String, password: String, firstName: String, lastName: String) {
        self.id = id
        self.userId = userId
        self.email = email
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.email == rhs.email &&
            lhs.password == rhs.password &&
            lhs.firstName == rhs.firstName &&
            lhs.lastName == rhs.lastName
    }
}

struct CreateUser: Migration {
    // Prepares the database for storing User models.
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        let result = database.schema("users")
            .id()
            .field("userId", .int, .required)
            .field("email", .string, .required)
            .field("password", .string, .required)
            .field("first_name", .string, .required)
            .field("last_name", .string)
            .create()
        
        let _ = User(userId: 1, email: "admin", password: "admin", firstName: "John", lastName: "Doe").save(on: database)
        
        return result
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users").delete()
    }
}

