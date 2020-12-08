//
//  Auth.swift
//  
//
//  Created by Maxim Safronov on 08.12.2020.
//

import Foundation
import Vapor

typealias UserDic = Dictionary<String,Any>
typealias UserResult = Dictionary<String,Any>

class Auth {
    let results = Results()
    
    struct LoginGetParam: Content {
        var username: String?
        var password: String?
    }

    struct LogoutGetParam: Content {
        var userId: Int?
    }

    struct changeUserDataGetParam: Content {
        var username: String?
        var password: String?
        var first_name: String?
        var last_name: String?
        var email: String?
        var userId: Int?
    }
    
    func doAction(action: String, queryString: URLQueryContainer?) -> String {
        switch action {
        case "login":
            return login(queryString)
        case "logout":
            return logout(queryString)
        case "change":
            return changeUserData(queryString)
        case "register":
            return register(queryString)
        default:
            return results.returnError(message: "Unknown method")
        }
    }
    
    func login(_ queryString: URLQueryContainer?) -> String {
        guard let query = try? queryString?.get(LoginGetParam.self),
            let userName = query.username,
            let userPassword = query.password,
            userName == "Somebody",
            userPassword == "Password" else {
                return results.returnError(message: "User not found")
        }
                    
        let user: UserDic = ["id_user": 12,
                          "user_login": userName,
                          "user_name": "John",
                          "user_lastname": "Doe"
        ]
        
        let result: UserResult = ["authToken": "some_authorizaion_token", "user": user]
        
        
        return results.returnResult(result)
    }
    
    func logout(_ queryString: URLQueryContainer?) -> String {
        guard let query = try? queryString?.get(LogoutGetParam.self),
            let _ = query.userId else {
                return results.returnError(message: "User not found")
        }
        
        return results.returnResult()
    }
    
    func changeUserData(_ queryString: URLQueryContainer?) -> String {
        guard let query = try? queryString?.get(changeUserDataGetParam.self),
            let _ = query.username,
            let _ = query.password,
            let _ = query.first_name,
            let _ = query.last_name,
            let _ = query.email,
            let _ = query.userId else {
                return results.returnError(message: "You must spercify all parameter")
        }
        
        return results.returnResult()
    }
    
    func register(_ queryString: URLQueryContainer?) -> String {
        guard let query = try? queryString?.get(changeUserDataGetParam.self),
            let _ = query.username,
            let _ = query.password,
            let _ = query.first_name,
            let _ = query.last_name,
            let _ = query.email else {
                return results.returnError(message: "You must spercify all parameter")
        }
        
        let answer: Dictionary<String,String> = ["userMessage": "Регистрация прошла успешно!"]
        
        return results.returnResult(answer)
    }
}
