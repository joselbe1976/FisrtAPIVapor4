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

final class UsersApp : Model, Content, ModelAuthenticatable, Validatable{

    // Security: Basic Auythetication
    static var usernameKey = \UsersApp.$email
    static var passwordHashKey = \UsersApp.$password
    
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
    
    // verifica
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
    
    // validaciones sobre los datos. de la clase (no es de seguridad). Se ejecuta cuando se hace el decode (recibo JSOn en el endpoint en el POST). Se valida justo antes del decode.
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: Validator.email, required: true)
        validations.add("password", as: String.self, is: .count(8...) && !.empty, required: true)
        // opodemos usar && y Ors.
        
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
