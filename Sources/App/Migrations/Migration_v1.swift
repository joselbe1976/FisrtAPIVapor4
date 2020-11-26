//
//  File.swift
//  
//
//  Created by JOSE LUIS BUSTOS ESTEBAN on 25/11/20.
//

import Vapor
import Fluent

struct CreateUsersApp_v1 : Migration {
    // la propia migracion / despliegue
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(UsersApp.schema)
            .id()
            .field(.email, .string, .required)
            .field(.password, .string, .required)
            .field(.activo, .bool, .required)
            .unique(on: .email) // email dato único
            .create()
    }
    
    
    // si se hecha a tras la migración
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(UsersApp.schema)
            .delete()
            
    }
    
    
}
