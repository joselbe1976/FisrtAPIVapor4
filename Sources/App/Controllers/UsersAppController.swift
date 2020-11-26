//
//  File.swift
//  
//
//  Created by JOSE LUIS BUSTOS ESTEBAN on 25/11/20.
//
import Vapor
import Fluent

struct UsersAppController : RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let app = routes.grouped("users")
        
        //Crear usuairos
        app.get("create", use: getCreateUser) // Create get
        app.post("create", use: postCreateUserCustomize) //create POst
        
        // consulta basica
        app.get("allusers", use: getAllUsers) // todos
        app.get("getuser", use: getUser) //  1 usuario
        app.post("postUser", use: postUser) // valida usuario
        //Cambio clave
        app.post("getUpdateUserPass", use: getUpdateUserPass)
    }
  
    
    
    //Crea usuario y devuelve httpstatus 200
    func getCreateUser(_ req:Request) throws -> EventLoopFuture<HTTPStatus>{
        guard let email = req.query[String.self, at: "email"],
              let password = req.query[String.self, at: "password"] else{
            
            throw Abort(.badRequest) // lanzamos error de mala solicitud
        }
        
        
        let digest = try req.password.hash(password) //encriptamos la clave
        let newUser = UsersApp( email: email, password: digest, activo: true)
        return newUser
                .create(on: req.db)
                .transform(to: .created)
            
    }
    
    //Crea usuario y devuelve el usuario
    func postCreateUser(_ req:Request) throws -> EventLoopFuture<UsersApp>{
        let userApp = try req.content.decode(UsersApp.self)
        userApp.password = try req.password.hash(userApp.password) // encripto la password
        
        return userApp.save(on: req.db).map{ userApp }
    }
    
    //Crea usuario y devuelve el usuario con un customizado
    func postCreateUserCustomize(_ req:Request) throws -> EventLoopFuture<UsersAppResponse>{
        let userApp = try req.content.decode(UsersApp.self)
        userApp.password = try req.password.hash(userApp.password) // encripto la password
        
        return userApp.save(on: req.db).flatMapThrowing{ //flatmap que permite throw en caso de error
            UsersAppResponse(email: userApp.email, id: try userApp.requireID())
        }
    }
    
    
    // devuelve todos los usuarios
    func getAllUsers(_ req:Request) throws -> EventLoopFuture<[UsersAppResponse]>{
        UsersApp.query(on: req.db)
                .all()
                .map{ users in
                    users.map{
                        UsersAppResponse(email: $0.email, id: $0.id!)
                    }
                }
    }
    
    // devuelve 1 Usuario
    func getUser(_ req:Request) throws -> EventLoopFuture<UsersAppResponse>{
       
        guard let email = req.query[String.self, at: "email"] else {
            throw Abort(.badRequest) // lanzamos error de mala solicitud
        }
        
        return UsersApp
                .query(on: req.db)
                .filter(\.$email == email)
                .first()
                .unwrap(or: Abort(.notFound))
                .map{
                    UsersAppResponse(email: $0.email, id: $0.id!)
                }
            
    }
    
    
    func postUser(_ req:Request) throws -> EventLoopFuture<HTTPStatus>{
        let userQuery = try req.content.decode(UsersQuery.self)
        
        return UsersApp
                .query(on: req.db)
                .filter(\.$email == userQuery.email)
                .first()
                .unwrap(or: Abort(.notFound))
                .map{ user in
                    if let okPass = try? req.password.verify(userQuery.password, created: user.password), okPass{
                        return .ok
                    } else {
                        return .badRequest
                    }
                    
                }
      
       
            
    }
    

    func getUpdateUserPass(_ req:Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let email = req.query[String.self, at: "email"],
              let oldPass = req.query[String.self, at: "oldPass"],
              let newPass = req.query[String.self, at: "newPass"] else {
            throw Abort(.badRequest)
        }
        return UsersApp
            .query(on: req.db)
            .filter(\.$email == email)
            .first()
            .unwrap(or: Abort(.notFound))
            .map { user   in
                if let okPass = try? req.password.verify(oldPass, created: user.password), okPass ,
                    let newPassHas = try? req.password.hash(newPass){
                    user.password = newPassHas
                    // grabamos la clave
                    let _ =  user.update(on: req.db)
                    return .ok
                    
                } else {
                    return .badRequest
                }
            }
    }
}
