//
//  RegisterResponse.swift
//  
//
//  Created by Maxim Safronov on 21.12.2020.
//

import Foundation
import Vapor

struct RegisterResponse: Content {
    let result: Int
    let userMessage: String
}
