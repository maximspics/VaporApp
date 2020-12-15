//
//  AuthRequests.swift
//  
//
//  Created by Maxim Safronov on 09.12.2020.
//

import Foundation
import Vapor

struct LoginRequest: Content {
    var login: String
    var password: String
}

struct LogoutRequest: Content {
    var id: Int
}

struct GetUserDataRequest: Content {
    var userId: Int
}

struct RegisterRequest: Content {
    let id: Int
    let userName: String
    let password: String
    let email: String
    let gender: String
    let creditCard: String
    let bio: String
}

struct ChangeDataRequest: Content {
    let userId: Int
    let login: String
    let password: String
    let email: String
    let firstName: String
    let lastName: String
}
