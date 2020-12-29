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
    var email: String?
    var login: String?
    var password: String?
    var newPassword: String?
    var firstName: String?
    var lastName: String?
}
