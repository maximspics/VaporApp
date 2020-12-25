//
//  LogoutResponse.swift
//  
//
//  Created by Maxim Safronov on 21.12.2020.
//

import Foundation
import Vapor

struct LogoutResponse: Content {
    let result: Int
    let userMessage: String
}
