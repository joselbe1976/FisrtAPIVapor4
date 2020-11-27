//
//  File.swift
//  
//
//  Created by JOSE LUIS BUSTOS ESTEBAN on 26/11/20.
//

import Vapor
import Fluent

extension FieldKey {
    static var name: FieldKey { "name" }
    static var birthDate: FieldKey { "birth_date" }
    static var nationality: FieldKey { "nationality" }
}

final class Composers : Model, Content {
    static let schema = "composers"
    
    @ID() var id:UUID?
    @Field(key: .name) var name:String
    @Field(key: .birthDate) var birthDate:Int?  // no siempre tenemos el año del compositor de nacimiento
    
    // Field FK. Opcional.
    @OptionalParent(key: "nationality") var nationality:Nationality?
    
    // Relacion Virtual Logica 1 a N
    @Children(for: \.$composer) var score:[Scores]
    
    init(){}
    
    init(id:UUID? = nil, name:String, birthDate:Int, nationality:UUID?){
        self.id = id
        self.name = name
        self.birthDate = birthDate
        self.$nationality.id = nationality
    }
}


struct ComposerCreate : Content {
    let name : String
    let birthDate:Int
    let nationality : String?
}
