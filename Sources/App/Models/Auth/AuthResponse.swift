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
    let id_user: Int
    let user_login: String
    let user_name: String
    let user_lastname: String
    let user_email: String
}

struct GetUserDataResponse: Content {
    let result, id_user: Int
    let user_login, user_password, user_name, user_lastname, user_email: String
}

struct RegisterResponse: Content {
    let result: Int
    let userMessage: String
}

struct ChangeDataResponse: Content {
    let result: Int
    let userMessage: String
}
