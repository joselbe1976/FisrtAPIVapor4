import Fluent
import Vapor

func routes(_ app: Application) throws {
  
    // registro controladore con Routes
    try app.register(collection: DemoController())
    try app.register(collection: UsersAppController())
}


struct JSONTest:Content{
    let firstName : String
    let lastName : String
}

struct ResponseTest:Content{
    let saludo:String
    let fullName: String
}
