//
//  File.swift
//  
//
//  Created by JOSE LUIS BUSTOS ESTEBAN on 24/11/20.
//

import Vapor

struct DemoController : RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let app = routes.grouped("demo")
        
        app.get("index", use: getIndex)

        
        
        app.get { req -> String in
             "It Works"
        }
        app.get("hello") { req -> String in
             "Hello, world!"
        }

        app.post("postDemo"){ req -> ResponseTest in
            let content = try req.content.decode(JSONTest.self)
            return ResponseTest(saludo: "Hola que haces!!!", fullName: content.firstName)
        }
        
        //Parametros normales de un Get
        app.get("users"){ req -> String in
            
            // recupero el parametro
            guard let parameters =  req.query[Int.self, at: "id"]  else {
                throw Abort(.notFound)
            }
            guard let name =  req.query[String.self, at: "name"]  else {
                throw Abort(.notFound)
            }
          
            
            return "Has pedido el id parametro: \(parameters) And name : \(name)"
            
        }
    }
    
    
    func getIndex(_ rec:Request) throws -> EventLoopFuture<View>{
        req.view.render("index", ["title": "Hello Vapor!"])
    }
}
