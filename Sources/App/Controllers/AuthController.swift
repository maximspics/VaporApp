//
//  AuthController.swift
//  
//
//  Created by Maxim Safronov on 08.12.2020.
//

import Vapor

class AuthController {
    func register(_ req: Request) throws -> EventLoopFuture<RegisterResponse> {
        guard let body = try? req.content.decode(RegisterRequest.self) else {
            throw Abort(.badRequest)
        }
    
        print(body)
        
        let response = RegisterResponse(
            result: 1,
            userMessage: "\(body.firstName), вы успешно зарегистрированы ПО МЕТОДИЧКЕ!"
        )
        print(response)
        
        return req.eventLoop.future(response)
    }
}
