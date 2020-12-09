//
//  AuthResponse.swift
//  
//
//  Created by Maxim Safronov on 09.12.2020.
//

import Foundation
import Vapor

struct LoginResponse: Content {
    let result: Int
    let user: User
    let authToken: String
}

struct LogoutResponse: Content {
    let result: Int
    let userMessage: String
}

struct User: Content {
    let id: Int
    let login: String
    let firstName: String
    let lastName: String
}

struct RegisterResponse: Content {
    let result: Int
    let userMessage: String
}

struct ChangeDataResponse: Content {
    let result: Int
    let userMessage: String
}
