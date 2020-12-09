//
//  AuthController.swift
//  
//
//  Created by Maxim Safronov on 08.12.2020.
//

import Vapor

class AuthController {
    let results = Results()
    
    func register(_ req: Request) throws -> EventLoopFuture<RegisterResponse> {
        guard let body = try? req.content.decode(RegisterRequest.self) else {
            throw Abort(.badRequest)
        }
    
        print(body)
        
        let response = RegisterResponse(
            result: 1,
            userMessage: "\(body.userName), вы успешно зарегистрированы!"
        )
        print(response)
        
        return req.eventLoop.future(response)
    }
    
    func login(_ req: Request) throws -> EventLoopFuture<LoginResponse> {
        guard let body = try? req.content.decode(LoginRequest.self) else {
            throw Abort(.badRequest)
        }
        
        print(body)
        
        let response = LoginResponse(
            result: 1,
            user: User(id: 123,
                       login: "geekbrains",
                       firstName: "John",
                       lastName: "Doe"),
            authToken: "some_authorization_token")
        
        print(response)
        
        return req.eventLoop.future(response)
    }
    
    func logout(_ req: Request) throws -> EventLoopFuture<LogoutResponse> {
        guard let body = try? req.content.decode(LogoutRequest.self) else {
            throw Abort(.badRequest)
        }
        
        print(body)
        
        let response = LogoutResponse(
            result: 1,
            userMessage: "Пользователь с id:\(body.id), вы успешно вышли из системы!")
        
        print(response)
        
        return req.eventLoop.future(response)
    }
    
    func changeData(_ req: Request) throws -> EventLoopFuture<ChangeDataResponse> {
        guard let body = try? req.content.decode(ChangeDataRequest.self) else {
            throw Abort(.badRequest)
        }
    
        print(body)
        
        let response = ChangeDataResponse(
            result: 1,
            userMessage: "\(body.userName), данные успешно изменены!"
        )
        print(response)
        
        return req.eventLoop.future(response)
    }
    
}
