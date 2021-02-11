//
//  AuthController.swift
//  
//
//  Created by Maxim Safronov on 08.12.2020.
//

import Fluent
import FluentSQLiteDriver
import Vapor

class AuthController {
    
    var results = Results()
    
    func register(_ req: Request) throws -> EventLoopFuture<String> {
        guard let user = try? req.content.decode(UserRequest.self),
              let email = user.email,
              let password = user.password,
              let firstName = user.firstName,
              let lastName = user.lastName else { throw Abort(.badRequest) }
        
        return User.query(on: req.db)
            .filter(\.$email, .equal, email)
            .limit(1)
            .first().flatMap { user -> EventLoopFuture<String> in
                if let _ = user {
                    return self.results.error(message: "Пользователь \(email) уже существует!", req)
                } else {
                    return User.query(on: req.db).max(\.$userId).flatMapAlways { result -> EventLoopFuture<String> in
                        switch result {
                        case let .success(maxId):
                            if let maxId = maxId {
                                return User(userId: maxId + 1, email: email, password: password, firstName: firstName, lastName: lastName)
                                    .save(on: req.db).flatMapAlways { (result) -> EventLoopFuture<String> in
                                        switch result {
                                        case .success():
                                            let result: Dictionary<String, Any> =
                                                [
                                                    "userMessage": "\(firstName), вы успешно зарегистрированы!"
                                                ]
                                            return self.results.returnResult(result, req)
                                        case .failure(_):
                                            return self.results.error(message: "Ошибка регистрации!", req)
                                        }
                                    }
                            }
                        case .failure(_):
                            return self.results.error(message: "Ошибка регистрации!", req)
                        }
                        return self.results.error(message: "Ошибка регистрации!", req)
                    }
                }
            }
    }
    
    func login(_ req: Request) throws -> EventLoopFuture<String> {
        guard let user = try? req.content.decode(UserRequest.self),
              let email = user.email,
              let password = user.password else { throw Abort(.badRequest) }
        
        return User.query(on: req.db)
            .filter(\.$email, .equal, email)
            .filter(\.$password, .equal, password)
            .limit(1)
            .first().flatMap { user -> EventLoopFuture<String> in
                if let user = user {
                    let result: Dictionary<String, Any> =
                        [
                            "user": [
                                "user_id": user.userId!,
                                "email": user.email!,
                                "first_name": user.firstName!,
                                "last_name": user.lastName!
                            ],
                            "authToken": "some_auth_token"
                        ]
                    return self.results.returnResult(result, req)
                } else {
                    return self.results.error(message: "Неправильный логин или пароль!", req)
                }
            }
    }
    
    func getUserData(_ req: Request) throws -> EventLoopFuture<String> {
        guard let user = try? req.content.decode(UserRequest.self),
              let userId = user.userId else { throw Abort(.badRequest) }
        
        return User.query(on: req.db)
            .filter(\.$userId, .equal, userId)
            .limit(1)
            .first().flatMap { user -> EventLoopFuture<String> in
                if let user = user {
                    let result: Dictionary<String, Any> =
                        [
                            "user_id": user.userId!,
                            "email": user.email!,
                            "password": user.password!,
                            "first_name": user.firstName!,
                            "last_name": user.lastName!
                        ]
                    return self.results.returnResult(result, req)
                } else {
                    return self.results.error(message: "Невозможно загрузить данные...", req)
                }
            }
    }
    
    func changeData(_ req: Request) throws -> EventLoopFuture<String> {
        guard let user = try? req.content.decode(UserRequest.self),
              let userId = user.userId,
              let userEmail = user.email,
              var userPassword = user.password,
              let newPassword = user.newPassword,
              let firstName = user.firstName,
              let lastName = user.lastName else
        {
            throw Abort(.badRequest)
        }
        
        return User.query(on: req.db)
            .filter(\.$userId, .equal, userId)
            .filter(\.$password, .equal, userPassword)
            .limit(1)
            .first().flatMap { user -> EventLoopFuture<String> in
                if let user = user {
                    if newPassword != "" {
                        userPassword = newPassword
                    }
                    if user.email == userEmail,
                       user.password == userPassword,
                       user.firstName == firstName,
                       user.lastName == lastName {
                        let result: Dictionary<String, Any> =
                            [
                                "result": 0,
                                "userMessage": "Вы не внесли никаких изменений"
                            ]
                        return self.results.returnResult(result, req)
                    }
                    user.email = userEmail
                    user.password = userPassword
                    user.firstName = firstName
                    user.lastName = lastName
                    
                    return user.update(on: req.db).flatMapAlways { (result) -> EventLoopFuture<String> in
                        switch result {
                        case .success():
                            let newFirstName = user.firstName ?? firstName
                            let result: Dictionary<String, Any> =
                                [
                                    "userMessage": "\(newFirstName), данные успешно изменены!"
                                ]
                            return self.results.returnResult(result, req)
                        case .failure(_):
                            return self.results.error(message: "Не удалось изменить данные...", req)
                        }
                    }
                }
                return self.results.error(message: "Неверный пароль!", req)
            }
    }
    
    func logout(_ req: Request) throws -> EventLoopFuture<String> {
        guard let user = try? req.content.decode(UserRequest.self),
              let userId = user.userId else { throw Abort(.badRequest) }
        
        return User.query(on: req.db)
            .filter(\.$userId, .equal, userId)
            .limit(1)
            .first().flatMap { user -> EventLoopFuture<String> in
                if let user = user {
                    let firstName = user.firstName ?? ""
                    let result: Dictionary<String, Any> =
                        [
                            "userMessage": "\(firstName), вы успешно вышли из системы!"
                        ]
                    return self.results.returnResult(result, req)
                } else {
                    return self.results.error(message: "Выйти из системы не удалось...", req)
                }
            }
    }
}
