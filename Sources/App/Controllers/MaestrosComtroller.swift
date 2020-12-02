//
//  File.swift
//  
//
//  Created by JOSE LUIS BUSTOS ESTEBAN on 30/11/20.
//

import Vapor
import Fluent


struct MaestrosComtroller : RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let app = routes.grouped("masters") // todos sobre rama xxx:8080/composers/
       
        app.get("categories", use:getAllCategories)
        app.get("nationalities", use:getAllNationalities)
        app.post("addCategories", use:addCategory)
        app.put("updateCategories", use:updateCategory)
        app.delete("deleteCategories", use:deleteCategories)
       
    }
    
    func addCategory(_ req:Request) throws -> EventLoopFuture<HTTPStatus>{
        let category = try req.content.decode(Categories.self)
        
        return category
            .create(on: req.db)
            .transform(to: .created)
    
    }

    
    func deleteCategories(_ req:Request) throws -> EventLoopFuture<HTTPStatus> {
        let category = try req.content.decode(Categories.self)
        return Categories
            .find(category.id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { delete in
                return delete.delete(on: req.db).transform(to: .noContent)
            }
    }
    
    
    
    func updateCategory(_ req:Request) throws -> EventLoopFuture<HTTPStatus>{
        let category = try req.content.decode(Categories.self)
        
        return Categories
            .find(category.id , on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap{ categoryDB in
                categoryDB.name = category.name
                return categoryDB
                    .update(on: req.db)
                    .transform(to: .created)
            }
        
    }
    
    
    func getAllCategories(_ req:Request) throws -> EventLoopFuture<[Categories]>{
    
        Categories.query(on: req.db).all()
    }
    
    
    func getAllNationalities(_ req:Request) throws -> EventLoopFuture<[Nationality]>{
    
        Nationality.query(on: req.db).all()
    }
    
}
