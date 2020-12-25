//
//  Login.swift
//  
//
//  Created by Maxim Safronov on 21.12.2020.
//

import Foundation
import Vapor

struct Login: Content {
    var login: String?
    var password: String?
}

