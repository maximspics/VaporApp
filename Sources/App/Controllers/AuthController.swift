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
    
    var req: Request!
    var resulter = Results()
    
    func getUserFutureById(id: Int, _ req: Request) -> EventLoopFuture<User?> {
        return User.query(on: req.db)
            .filter(\.$userId, .equal, id)
            .limit(1)
            .first()
    }
    func getUserFutureByLoginPassword(login: String, password: String, _ req: Request) -> EventLoopFuture<User?> {
        return User.query(on: req.db)
            .filter(\.$username, .equal, login)
            .filter(\.$password, .equal, password)
            .limit(1)
            .first()
    }
    func getUserFutureByLogin(login: String, _ req: Request) -> EventLoopFuture<User?> {
        return User.query(on: req.db)
            .filter(\.$username, .equal, login)
            .limit(1)
            .first()
    }
    func getUserFurureByIdPassword(id: Int, password: String, _ req: Request) -> EventLoopFuture<User?> {
        return User.query(on: req.db)
            .filter(\.$userId, .equal, id)
            .filter(\.$password, .equal, password)
            .limit(1)
            .first()
    }
    
    func getUserByLogin(login: String, _ req: Request) -> EventLoopFuture<RegisterResponse?> {
        return getUserFutureByLogin(login: login, req)
            .map { user -> RegisterResponse? in
                if let _ = user {
                    return RegisterResponse(result: 1, userMessage: "")
                } else {
                    return nil
                }
            }
    }
    
    func register(_ req: Request) throws -> EventLoopFuture<RegisterResponse> {
        
        guard let user = try? req.content.decode(UserRequest.self),
              let userName = user.username,
              let userPassword = user.password,
              let firstName = user.firstName,
              let lastName = user.lastName,
              let userEmail = user.email else {
            throw Abort(.badRequest, reason: "Регистрация не удалась, что-то пошло не так...")
        }
        
        return getUserFutureByLogin(login: userName, req).flatMap { user -> EventLoopFuture<RegisterResponse> in
            
            if let _ = user {
                let response = RegisterResponse(
                    result: 0,
                    userMessage: "Пользователь \(userName) уже существует!")
                return req.eventLoop.future(response)
                
            } else {
                
                return User.query(on: req.db).max(\.$userId).flatMapAlways { result -> EventLoopFuture<RegisterResponse> in
                    switch result {
                    case let .success(maxId):
                        if let maxId = maxId {
                            return User(userId: maxId + 1, username: userName, password: userPassword, firstName: firstName, lastName: lastName, email: userEmail)
                                .save(on: req.db).flatMapAlways { (result) -> EventLoopFuture<RegisterResponse> in
                                    switch result {
                                    case .success():
                                        let response = RegisterResponse(
                                            result: 1,
                                            userMessage: "\(firstName), вы успешно зарегистрированы!")
                                        return req.eventLoop.future(response)
                                    case .failure(_):
                                        let response = RegisterResponse(
                                            result: 0,
                                            userMessage: "Ошибка регистрации!")
                                        return req.eventLoop.future(response)
                                    }
                                }
                        }
                    case .failure(_):
                        let response = RegisterResponse(
                            result: 0,
                            userMessage: "Ошибка регистрации!")
                        return req.eventLoop.future(response)
                    }
                    
                    let response = RegisterResponse(
                        result: 0,
                        userMessage: "Ошибка регистрации!")
                    return req.eventLoop.future(response)
                }
            }
        }
    }
    
    func login(_ req: Request) throws -> EventLoopFuture<LoginResponse> {
        
        guard let query = try? req.content.decode(Login.self),
              let userName = query.login,
              let userPassword = query.password else {
            throw Abort(.badRequest, reason: "Не удалось войти...")
        }
        
        return getUserFutureByLoginPassword(login: userName, password: userPassword, req).flatMap { user -> EventLoopFuture<LoginResponse> in
            if let user = user {
                
                let userResponse = UserResponse(id_user: user.userId!,
                                                user_login: user.username,
                                                user_name: user.firstName,
                                                user_lastname: user.lastName ?? "",
                                                user_email: user.email)
                let response = LoginResponse(result: 1,
                                             user: userResponse,
                                             authToken: "some_auth_token")
                print(response)
                return req.eventLoop.future(response)
            }
            
            let response = LoginResponse(result: 0, user: nil, authToken: nil)
            print(response)
            return req.eventLoop.future(response)
        }
    }
    
    func getUserData(_ req: Request) throws -> EventLoopFuture<GetUserDataResponse> {
        
        guard let user = try? req.content.decode(GetUserData.self),
              let userId = user.userId else {
            throw Abort(.badRequest, reason: "Невозможно загрузить данные...")
        }
        
        return getUserFutureById(id: userId, req).flatMap { user -> EventLoopFuture<GetUserDataResponse> in
            if let user = user {
                let response = GetUserDataResponse(
                    result: 1,
                    id_user: user.userId,
                    user_login: user.username,
                    user_password: user.password,
                    user_name: user.firstName,
                    user_lastname: user.lastName,
                    user_email: user.email
                )
                print(response)
                return req.eventLoop.future(response)
            }
            let response = GetUserDataResponse(
                result: 0,
                id_user: nil,
                user_login: nil,
                user_password: nil,
                user_name: nil,
                user_lastname: nil,
                user_email: nil
            )
            
            return req.eventLoop.future(response)
        }
    }
    
    func changeData(_ req: Request) throws -> EventLoopFuture<ChangeDataResponse> {
        guard let user = try? req.content.decode(ChangeData.self),
              let userId = user.userId,
              let userName = user.email,
              var userPassword = user.password,
              let firstName = user.firstName,
              let lastName = user.lastName,
              let userEmail = user.email else {
            throw Abort(.badRequest, reason: "Не удалось изменить данные")
        }
        print(userId)
        print(userPassword)
        let newPassword = user.newPassword
        
        return getUserFurureByIdPassword(id: userId, password: userPassword, req).flatMap { user -> EventLoopFuture<ChangeDataResponse> in
            if let user = user {
                
                if newPassword != "" {
                    userPassword = newPassword!
                }
                print(userPassword)
                user.firstName = firstName
                user.lastName = lastName
                user.email = userEmail
                user.password = userPassword
                user.username = userName
                
                return user.update(on: req.db).flatMapAlways { (result) -> EventLoopFuture<ChangeDataResponse> in
                    switch result {
                    case .success():
                        let response = ChangeDataResponse(
                            result: 1,
                            userMessage: "\(user.firstName), данные успешно изменены!"
                        )
                        print(response)
                        
                        return req.eventLoop.future(response)
                    case .failure(_):
                        let response = ChangeDataResponse(
                            result: 0,
                            userMessage: "Данные не обновлены!"
                        )
                        print(response)
                        
                        return req.eventLoop.future(response)
                    }
                }
            }
            let response = ChangeDataResponse(
                result: 0,
                userMessage: "Неверный пароль!"
            )
            print(response)
            
            return req.eventLoop.future(response)
        }
    }
    
    func logout(_ req: Request) throws -> EventLoopFuture<LogoutResponse> {
        guard let user = try? req.content.decode(Logout.self),
              let userId = user.userId else {
            throw Abort(.badRequest)
        }
        return getUserFutureById(id: userId, req).flatMap { user -> EventLoopFuture<LogoutResponse> in
            if let user = user {
                let response = LogoutResponse(
                    result: 1,
                    userMessage: "\(user.firstName), вы успешно вышли из системы!")
                
                print(response)
                
                return req.eventLoop.future(response)
            } else {
                let response = LogoutResponse(
                    result: 0,
                    userMessage: "Выйти из системы не удалось")
                
                print(response)
                
                return req.eventLoop.future(response)
            }
        }
    }
}
