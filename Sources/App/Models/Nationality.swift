//
//  File.swift
//  
//
//  Created by JOSE LUIS BUSTOS ESTEBAN on 26/11/20.
//

import Vapor
import Fluent


final class Nationality : Model, Content {
    static let schema = "nationality"
    
    @ID() var id:UUID?
    @Field(key: "country") var country:String

    init(){}
    
    init(id:UUID? = nil, country:String){
        self.id = id
        self.country = country
    }
}
