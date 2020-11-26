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

    // migraciones de version 1
    app.migrations.add(CreateUsersApp_v1())
    
    //encriptacion del sistema
    app.passwords.use(.bcrypt)

    // register routes
    try routes(app)
}
