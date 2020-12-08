//
//  RegisterRequest.swift
//  
//
//  Created by Maxim Safronov on 02.12.2020.
//

import Foundation
import Vapor

struct RegisterRequest: Content {
    var login: String
    var password: String
    var email: String
    var firstName: String
    var lastName: String?
}
