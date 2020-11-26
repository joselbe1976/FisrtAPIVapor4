//
//  File.swift
//  
//
//  Created by JOSE LUIS BUSTOS ESTEBAN on 24/11/20.
//

import Vapor

struct DemoController : RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let app = routes.grouped("demo") // todos sobre rama xxx:8080/demo/
        
        app.get("index", use: getIndex)
        app.get (use: getRoot)
        app.get("hello", use: geHelloWorld)
        app.post("postDemo", use:postDemo)
        app.get("users", use: getUsersId)
        app.get("ok", use: getOK)
    }
    
    
    func getIndex(_ req:Request) throws -> EventLoopFuture<View>{
        req.view.render("index", ["title": "Hello Vapor!"])
    }
    
    func getRoot(_ req:Request) throws -> String{
         "It Works"
    }
    func geHelloWorld(_ req:Request) throws -> String{
         "Hello World!"
    }
    func postDemo(_ req:Request) throws -> ResponseTest{
        let content = try req.content.decode(JSONTest.self)
        return ResponseTest(saludo: "Hola que haces!!!", fullName: content.firstName)
    }
    
    //acceso parametros por la URL como parametros normales
    func getUsersId(_ req:Request) throws -> String{
        // recupero el parametro
        guard let parameters =  req.query[Int.self, at: "id"]  else {
            throw Abort(.notFound)
        }
        guard let name =  req.query[String.self, at: "name"]  else {
            throw Abort(.notFound)
        }

        return "Has pedido el id parametro: \(parameters) And name : \(name)"
    }
    
    // Accesso mediante parametros  /demo/users/10010 <= eso seria id
    // req.parameters.get("id", as: Int.self
    
    
    func getOK( _ req:Request) throws -> HTTPStatus {
        .ok // Codigo 200
    }
    
    
}
