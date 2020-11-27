//
//  File.swift
//  
//
//  Created by JOSE LUIS BUSTOS ESTEBAN on 26/11/20.
//

import Vapor
import Fluent


final class Scores : Model, Content {
    static let schema = "scores"
    
    @ID() var id:UUID?
    @Field(key: "title") var title:String
    @Field(key: "year") var year:Int? // a veces no tenemos el año
    @Field(key: "number_tracks") var numberTracks:Int? // NUmero pistas del CD
    
    //FK N->1
    @Parent(key: "composer") var composer:Composers  // Obligatorio el campo
    
    // Categoria. 1 a 1 . Opcional
    @OptionalParent(key: "category")  var category:Categories?

    // Relacion N a N Scores con Users (through tabala de union), from = keypath de la tabla Subliginf N-N de Score, = to: el otro campo tabla N- A N este caos user
    @Siblings(through: UsersScores.self, from: \.$score, to: \.$user) var users:[UsersApp]
    
    init(){}
    
    init(id:UUID? = nil, title:String, year:Int?, numberTracks:Int?, composer:UUID, category:Int?){
        self.id = id
        self.title = title
        self.year = year
        self.numberTracks = numberTracks
        self.$composer.id = composer
        self.$category.id = category
        
    }
}


struct ScoresRequestCreate : Content {
    let title : String
    let year : Int?
    let numtracks : Int?  // optional
    let composer : String // name of Composer
    let category : String?  // name of category. Optional
}
