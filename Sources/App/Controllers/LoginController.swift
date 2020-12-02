//
//  File.swift
//  
//
//  Created by JOSE LUIS BUSTOS ESTEBAN on 2/12/20.
//
import Vapor

struct LoginController : RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let app = routes.grouped("api","login")
            .grouped(UsersApp.authenticator())
            .grouped(UsersApp.guardMiddleware())// autenticacion basica de UsersApp
        
        app.post("init", use: login)
        
    }
    
    func login(_ req:Request) throws -> String {
        let user = try req.auth.require(UsersApp.self  )
        
        return "Hola \(user.email)"
    }
    
    
    
}
