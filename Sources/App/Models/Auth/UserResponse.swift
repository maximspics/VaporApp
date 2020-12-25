//
//  File.swift
//  
//
//  Created by Maxim Safronov on 21.12.2020.
//

import Foundation
import Vapor

struct UserResponse: Content {
    let id_user: Int
    let user_login: String
    let user_name: String
    let user_lastname: String
    let user_email: String
}
