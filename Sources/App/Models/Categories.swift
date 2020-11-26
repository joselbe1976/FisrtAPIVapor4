//
//  File.swift
//  
//
//  Created by JOSE LUIS BUSTOS ESTEBAN on 26/11/20.
//

import Vapor
import Fluent


final class Categories : Model {
    static let schema = "categories"
    
    @ID(custom: "id") var id:Int?
    @Field(key: "name") var name:String
    
    // relacion Virtual para ver Scores de una categoria
    @Children(for: \.$category) var scores:[Scores]

    init(){}
    
    init(id:Int? = nil, name:String){
        self.id = id
        self.name = name
    }
}
