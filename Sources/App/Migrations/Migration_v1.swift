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


struct CreateNationality_v1: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Nationality.schema)
            .id()
            .field("country", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Nationality.schema)
            .delete()
    }
}


struct CreateCategories_v1: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Categories.schema)
            .field("id", .int, .identifier(auto: true))
            .field("name", .string, .required)
            .unique(on: "id") // PK
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Categories.schema)
            .delete()
    }
}


struct CreateComposers_v1: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Composers.schema)
            .id()
            .field("name", .string, .required)
            .field("birth_date", .int) //is optional NOt required
            .field("nationality", .uuid, .sql(.default(UUID().uuidString))) // not required, default value to the field
            .foreignKey("nationality", references: Nationality.schema, "id",
                        onDelete: .setDefault, onUpdate: .cascade) // FK
            .unique(on: "name") // clave dato unico. Restriccion.
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Composers.schema)
            .delete()
    }
}



struct CreateScores_v1: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Scores.schema)
            .id()
            .field("title", .string, .required)
            .field("year", .int) //is optional NOt required
            .field("number_tracks", .int) // not required
            .field("composer", .uuid, .required)
            .foreignKey("composer", references: Composers.schema, "id", onDelete: .cascade, onUpdate: .cascade, name: "FK_Composer") // FK con Tabla Composers
            .field("category", .int) // not required
            .foreignKey("category", references: Categories.schema, "id", onDelete: .setNull, onUpdate: .cascade, name: "FK_Categories")  // FK con Tabla Categories
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Scores.schema)
            .delete()
    }
}


// Tablas Sublins no se crean FK, porque las bbdd no los soportan: La relacion lo hace a nivel logico,
// pero fisicamente no se representa
struct CreateUsersScores_v1: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(UsersScores.schema)
            .id()
            .field("score", .uuid, .required, .references(Scores.schema, "id")) // Hay una referencia al modelo logico
            .field("user", .uuid, .required, .references(UsersApp.schema, "id")) // referencia auuda a la relaciones logicas. Ayuda a la bbdd logica entienda mejor la relacion
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(UsersScores.schema)
            .delete()
    }
}



struct CreateCategoriesData: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
      let cat1 = Categories(name: "Accion")
      let cat2 = Categories(name: "Romantica")
      let cat3 = Categories(name: "Epic")
      let cat4 = Categories(name: "Drama")
      
        // ejecutar un array de EventLoopFuture<void> (un bucle de ejecucion)
      return .andAllSucceed([
            cat1.create(on: database),
            cat2.create(on: database),
            cat3.create(on: database),
            cat4.create(on: database)
        ], on: database.eventLoop)
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        Categories.query(on: database).delete()  // eliminamos la recuperacion de todos los datos (query)
    }
    
    

    
}



struct CreateUserToken_V1: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(UserToken.schema)
            .id()
            .field("user_id", .uuid, .references(UsersApp.schema, "id"))
            .field("tokenValue", .string, .required)
            .unique(on: "tokenValue")
            .field("create", .datetime, .required)
            .field("expiration", .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(UserToken.schema)
            .delete()
    }
    
    

    
}
