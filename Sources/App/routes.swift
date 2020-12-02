import Fluent
import Vapor

func routes(_ app: Application) throws {
  
    // registro controladore con Routes
    try app.register(collection: DemoController())
    try app.register(collection: UsersAppController())
    try app.register(collection: ComposerController())
    try app.register(collection: ScoresController())
    try app.register(collection: ScoresUsersController())
    try app.register(collection: MaestrosComtroller())
    
}


struct JSONTest:Content{
    let firstName : String
    let lastName : String
}

struct ResponseTest:Content{
    let saludo:String
    let fullName: String
}
