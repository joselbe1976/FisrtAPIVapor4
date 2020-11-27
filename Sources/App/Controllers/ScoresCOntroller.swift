//
//  File.swift
//  
//
//  Created by JOSE LUIS BUSTOS ESTEBAN on 27/11/20.
//

import Vapor
import Fluent


struct ScoresController : RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let app = routes.grouped("scores") // todos sobre rama xxx:8080/scores/
        app.post("create", use: newScore)
        app.get("find", use: getScore)
        app.get("all", use: getAllScore)
        app.delete("delete", use: deleteScore)
    }
    

    func getAllScore(_ req:Request) throws -> EventLoopFuture<[Scores]>{
      
        return Scores
            .query(on: req.db)
            .with(\.$composer) // relacion de compositor
            .with(\.$composer){ composer in
                composer.with(\.$nationality)  // relacion de la nacionalidad del compositor
            }
            .with(\.$category)
            .all()
    
    }
    
    func getScore(_ req:Request) throws -> EventLoopFuture<Scores>{
        guard let param = req.query[String.self, at: "score"] else {
            throw Abort(.notFound)
        }
        
        return Scores
            .query(on: req.db)
            .with(\.$composer) // relacion de compositor
            .with(\.$composer){ composer in
                composer.with(\.$nationality)  // relacion de la nacionalidad del compositor
            }
            .with(\.$category)
            .filter(\.$title == param)
            .first()
            .unwrap(or: Abort(.notFound))
    }
    
    func deleteScore(_ req:Request) throws -> EventLoopFuture<HTTPStatus>{
        guard let param = req.query[String.self, at: "score"] else {
            throw Abort(.notFound)
        }
        
        return Scores
            .query(on: req.db)
            .filter(\.$title == param)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap{ score in
                score.delete(on: req.db)
            }
            .transform(to: .ok)
    }
    
     
    func newScore(_ req:Request) throws -> EventLoopFuture<HTTPStatus>{
        let scoreCreate = try req.content.decode(ScoresRequestCreate.self)
        
        return Composers
            .query(on: req.db)
            .filter(\.$name == scoreCreate.composer)
            .first()
            .flatMap{ composer in
                if let compositor = composer?.id {
                    // Si existe el compositor
                    return newScoreAux(req: req, composerId: compositor, scoreCreate: scoreCreate)
                   
                }
                else {
                    // no existe el compositor. Debemos crearlo.
                    let newComposer = Composers(name: scoreCreate.composer, birthDate: 1800, nationality: nil)
                    return newComposer
                        .create(on: req.db)
                        .flatMap{
                            return newScoreAux(req: req, composerId: newComposer.id!, scoreCreate: scoreCreate)
                        }
                }
            }
    }

    // funcion auxiliar
    func newScoreAux(req:Request, composerId:UUID, scoreCreate:ScoresRequestCreate)  -> EventLoopFuture<HTTPStatus>{
        if let nmcategoria = scoreCreate.category {
            // Si viene la categoria. La buscamos y guardamos
            
            return Categories
                .query(on: req.db)
                .filter(\.$name == nmcategoria)
                .first()
                .flatMap{ cat in
                    
                    if let idCategoria = cat?.id{
                        // existe la categoria
                        let newScore = Scores(title: scoreCreate.title, year: scoreCreate.year, numberTracks: scoreCreate.numtracks, composer: composerId, category: idCategoria)
                        return newScore
                            .create(on: req.db)
                            .transform(to: .ok)
                    }else{
                        // no existe la categoria
                       return  req.eventLoop.makeSucceededFuture(HTTPStatus.badRequest)
                    }
                }
            
        } else {
            // no viene la categoria
            let newScore = Scores(title: scoreCreate.title, year: scoreCreate.year, numberTracks: scoreCreate.numtracks, composer: composerId, category: nil)
            return newScore
                .create(on: req.db)
                .transform(to: .ok)
        }
    }


}
