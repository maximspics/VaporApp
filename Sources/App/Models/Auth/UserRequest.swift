//
//  UserRequest.swift
//  
//
//  Created by Maxim Safronov on 23.12.2020.
//

import Foundation
import Vapor

struct UserRequest: Content {
    var userId: Int?
    var username: String?
    var password: String?
    var firstName: String?
    var lastName: String?
    var email: String?
}
