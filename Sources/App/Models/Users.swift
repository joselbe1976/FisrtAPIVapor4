//
//  File.swift
//  
//
//  Created by JOSE LUIS BUSTOS ESTEBAN on 25/11/20.
//

import Vapor
import Fluent

extension FieldKey {
    static var email: FieldKey { "email" }
    static var password: FieldKey { "password" }
    static var activo: FieldKey { "activo" }
}

final class UsersApp : Model, Content {
    static var schema = "users_app" //identificador de la tabla
    
    @ID() var id : UUID? // Identificador del registro. Opcional para que nil y lo calcule vapor
    @Field(key: .email) var email:String
    @Field(key: .password) var password:String
    @Field(key: .activo) var activo:Bool
    
    // Relacion N a N con Scores
    @Siblings(through: UsersScores.self, from: \.$user, to: \.$score ) var scores:[Scores]
    
    // constructor Vacio. Obligatorio
    init(){}
    // constructor. Obligatorio todos los campos.
    init(id:UUID? = nil, email: String, password:String, activo:Bool){
        self.id = id
        self.email = email
        self.password = password
        self.activo = activo
    }
}

struct UsersAppResponse: Content {
    let email : String
    let id:UUID
}

struct UsersQuery : Content {
    let email : String
    let password : String
}

struct UsersQueryPass: Content {
    let email : String
    let password : String
    let newPassword : String
}

struct UsersQueryID :Content{
    let id:UUID
}
