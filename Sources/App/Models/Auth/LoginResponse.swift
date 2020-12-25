//
//  LoginResponse.swift
//  
//
//  Created by Maxim Safronov on 21.12.2020.
//

import Foundation
import Vapor

struct LoginResponse: Content {
    let result: Int
    let user: UserResponse?
    let authToken: String?
}
