import Fluent
import FluentSQLiteDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // directorio publico. Creamos directorio en Raiz.
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // configuracion SQL Lite
    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
       // .file = Disco
       // .memory = solo en memoria
    
    // migracion
  //  app.migrations.add(CreateTodo())

    // Uso de Leaf
    app.views.use(.leaf)
    app.leaf.cache.isEnabled = app.environment.isRelease // activa la cache solo en produccion, y no en Desarrollo

    // migraciones de version 1. Ojo al Orden de ejecucion de los Script
    app.migrations.add(CreateUsersApp_v1())
    app.migrations.add(CreateNationality_v1())
    app.migrations.add(CreateCategories_v1())
    app.migrations.add(CreateComposers_v1())
    app.migrations.add(CreateScores_v1())
    app.migrations.add(CreateUsersScores_v1())

    // Data
    app.migrations.add(CreateCategoriesData())
    
    //encriptacion del sistema
    app.passwords.use(.bcrypt)

    // register routes
    try routes(app)
}
