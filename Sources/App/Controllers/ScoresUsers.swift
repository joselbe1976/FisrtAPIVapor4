//
//  File.swift
//  
//
//  Created by JOSE LUIS BUSTOS ESTEBAN on 30/11/20.
//

import Vapor
import Fluent

struct ScoresUsersController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let app = routes.grouped("scoresUsers") // todos sobre rama xxx:8080/scoresUsers/
        app.post(":scoreID" , "user", ":userID", use: addUserScore)
        app.get(":userID" , use: getScoresFromUser)
        //app.get("all" , use: getAll)
        
        
        app.post("users" , use: postUserFromScore)
        app.delete(":scoreID" , "user", ":userID", use: deleteUserScore)
    }
    
    
    
    
    //eliminar asociacion
    func deleteUserScore(_ req:Request) throws -> EventLoopFuture<HTTPStatus>{
        let  ScoresQuery = Scores
                            .find(req.parameters.get("scoreID"), on: req.db)  // find solo aceptar buscar por ID, y hace un query y un First
                            .unwrap(or: Abort(.notFound))
           
        let UsersAppQuery = UsersApp
                            .find(req.parameters.get("userID"), on: req.db)
                            .unwrap(or: Abort(.notFound))
        
        
        return ScoresQuery.and(UsersAppQuery)
            .flatMap{ score, user in
                    score
                        .$users
                        .detach(user, on: req.db)
                        .transform(to: .noContent)
            }
    
    }
    
    // Usuarios de un score
    
    func postUserFromScore(_ req:Request) throws -> EventLoopFuture<[UsersAppResponse]>{
        let score = try req.content.decode(Scorequery.self)
        
        return Scores
            .query(on: req.db)
            .filter(\.$title == score.title)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap{ score in
                score.$users
                    .query(on: req.db)
                    .all()
                    .map{users in
                        users.compactMap { user in
                            UsersAppResponse(email: user.email, id: user.id!)
                        }
                    }
                
            }
    }
    
    
    // Scores de un usuario
    func getScoresFromUser(_ req:Request) throws -> EventLoopFuture<[Scores]>{
        
        return UsersApp
            .find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap{ user in
                user.$scores
                    .query(on: req.db)
                    .with(\.$composer)
                    .with(\.$category)
                    .with(\.$composer) {
                        composer in
                        composer.with(\.$nationality) // nacionalidad del compositor
                    }
                    .all() //accedemos por la relacion de usuarios con scores por la relacion Siblings
                
            }
    }
    
    
    
    // añadir record
    func addUserScore(_ req:Request) throws -> EventLoopFuture<HTTPStatus>{
        // el find = filter + first. A demas usa el index.
        
        let  ScoresQuery = Scores
                            .find(req.parameters.get("scoreID"), on: req.db)
                            .unwrap(or: Abort(.notFound))
           
        let UsersAppQuery = UsersApp
                            .find(req.parameters.get("userID"), on: req.db)
                            .unwrap(or: Abort(.notFound))
        
          // se lanza ambos en 2 hilos concurrentes y cuando respondan ambas, se ejecuta el flatmap.
        return ScoresQuery.and(UsersAppQuery)
            .flatMap{ score, user in
                
                guard let scoreUUId = UUID(uuidString: req.parameters.get("scoreID")!),
                      let userUUid = UUID(uuidString: req.parameters.get("userID")!) else {
                    return req.eventLoop.makeFailedFuture(Abort(.badRequest))
                }
                
                 return UsersScores.query(on: req.db)
                    .group(.and){ group in
                        group
                            .filter(\.$score.$id == scoreUUId)
                            .filter(\.$user.$id == userUUid)
                    }
                    .first()
                    .flatMap{ exist in
                        if exist == nil {
                            return score
                                .$users
                                .attach(user, on: req.db)
                                .transform(to: .created)
                            
                            /*Esto crea el registro en la tabla intermedia, accediendo desde scores.
                             Para ello usamos los Siblings de las clases. Accedemos desde Score, pero podría ser desde users
                             */
                        } else {
                            return req.eventLoop.makeFailedFuture(Abort(.badRequest))
                        }
                    }
            }
                
            
        
        /*
         
          NO ES EFICIENTE
        return Scores
            .find(req.parameters.get("scoreID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap{ score in
                return UsersApp
                    .find(req.parameters.get("userID"), on: req.db)
                    .unwrap(or: Abort(.notFound))
                    .flatMap{ user in
                        
                    }
                
            }
 */
    }
 
    
    
}
