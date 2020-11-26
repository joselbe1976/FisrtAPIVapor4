//
//  File.swift
//  
//
//  Created by JOSE LUIS BUSTOS ESTEBAN on 26/11/20.
//

import Fluent
import Vapor

final class UsersScores : Model {
    static let schema = "users_scores"
    
    @ID() var id:UUID?
    @Parent(key: "score") var score:Scores
    @Parent(key: "user") var user:UsersApp
    
    init(){}
    
    init(id: UUID? = nil, score:Scores, user:UsersApp) throws{
        self.id = id
        self.$score.id = try score.requireID()
        self.$user.id = try user.requireID()
    }
    
    // hay que en scores y userapps las relaciones entre ambas
}
