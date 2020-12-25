//
//  File.swift
//  
//
//  Created by Maxim Safronov on 21.12.2020.
//

import Foundation
import Vapor

struct ChangeData: Content {
    let userId: Int?
    let login: String?
    let password: String?
    let newPassword: String?
    let email: String?
    let firstName: String?
    let lastName: String?
}
