//
//  File.swift
//  
//
//  Created by JOSE LUIS BUSTOS ESTEBAN on 27/11/20.
//

import Vapor
import Fluent


struct ComposerController : RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let app = routes.grouped("composers") // todos sobre rama xxx:8080/composers/
        app.post("create", use:newComposer)
        app.get("find", use:getComposer)
        
        app.get("all", use:getAllComposer)
    }
    
    // New Composer
    func newComposer(_ req:Request) throws -> EventLoopFuture<HTTPStatus>{
        let composerCreate = try req.content.decode(ComposerCreate.self)
        
        if let nationality = composerCreate.nationality {
            // viene nacionalidad, verificamos si existe
            
            return Nationality
                .query(on: req.db)
                .filter(\.$country == nationality)
                .first()
                .flatMap{ country in
                    if let countryOK = country {
                        let newComposer = Composers(name: composerCreate.name, birthDate: composerCreate.birthDate, nationality: countryOK.id)
                        
                        return newComposer
                            .create(on: req.db)
                            .transform(to: .ok)
                    }else{
                        // creamos el Country
                        let newCountry = Nationality(country: nationality)
                        let newComposer = Composers(name: composerCreate.name, birthDate: composerCreate.birthDate, nationality: nil)
                        
                        return newCountry
                            .create(on: req.db)
                            .flatMap{
                                // grabamos el composer
                                newComposer.$nationality.id = newCountry.id
                                return newComposer
                                    .create(on: req.db)
                                    .transform(to: .ok)
                            }
                    }
                }
            
        }else {
            // grabacion sin nacionalidad, porque viene nil
            let newComposer = Composers(name: composerCreate.name, birthDate: composerCreate.birthDate, nationality: nil)
            return newComposer.create(on: req.db).transform(to: .ok)
        }

    }

    // devuelve un compositor buscando por el nombre
    func getComposer(_ req:Request) throws -> EventLoopFuture<Composers>{
        guard let param = req.query[String.self, at: "composer"] else {
            throw Abort(.notFound)
        }
        
        return Composers
            .query(on: req.db)
            .with(\.$nationality) // que pille la nacionalidad y saque el nombre por la relacion FK
            .filter(\.$name == param) //filtro por nombre
            .first()
            .unwrap(or: Abort(.notFound))
    }
    
    
    func getAllComposer(_ req:Request) throws -> EventLoopFuture<[Composers]>{
        return Composers
            .query(on: req.db)
            .with(\.$nationality) // que pille la nacionalidad y saque el nombre por la relacion FK
            .all()
    }


}
