//
//  GetUserDataResponse.swift
//  
//
//  Created by Maxim Safronov on 21.12.2020.
//

import Foundation
import Vapor

struct GetUserDataResponse: Content {
    let result, id_user: Int?
    let user_login, user_password, user_name, user_lastname, user_email: String?
}
