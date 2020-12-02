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
        app.put("update", use: updateScore)
    }
    
    
    
    func updateScore(_ req:Request) throws -> EventLoopFuture<HTTPStatus>{
        let score = try req.content.decode(ScoresRequestUpdate.self)
        
        return Scores
            .query(on: req.db)
            .filter(\.$id == score.id)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap{ DBScore in
                //Desempaqueto cada opcional. Puede venir 1 campo o todos en el PUT
                if let title = score.title {
                    DBScore.title = title
                }
                if let numtracks = score.numtracks {
                    DBScore.numberTracks = numtracks
                }
                if let year = score.year {
                    DBScore.year = year
                }
                if let idcategory = score.idcategory {
                    DBScore.$category.id = idcategory
                }
                if let idcomposer = score.idcomposer {
                    DBScore.$composer.id = idcomposer
                }
                
                return DBScore
                    .update(on: req.db)
                    .transform(to: .ok)
            }
        
        
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
            .find(UUID(param) , on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap{ score in
                score.delete(on: req.db)
            }
            .transform(to: .ok)
    }
    
     
    func newScore(_ req:Request) throws -> EventLoopFuture<HTTPStatus>{
        let scoreCreate = try req.content.decode(ScoresRequestCreate.self)
        
        return Composers
            .find(scoreCreate.composer, on: req.db)
            .flatMap{ composer in
                if let compositor = composer?.id {
                    // Si existe el compositor
                    return newScoreAux(req: req, composerId: compositor, scoreCreate: scoreCreate)
                   
                }
                else {
                    // no existe el compositor. ERROR
                    return  req.eventLoop.makeSucceededFuture(HTTPStatus.notFound)
                }
            }
    }

    // funcion auxiliar
    func newScoreAux(req:Request, composerId:UUID, scoreCreate:ScoresRequestCreate)  -> EventLoopFuture<HTTPStatus>{
        if let idcategoria : Int = Int(scoreCreate.category!) {
            // Si viene la categoria. La buscamos y guardamos
            
            return Categories
                .find(idcategoria, on: req.db)
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

