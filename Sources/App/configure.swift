import Fluent
import FluentSQLiteDriver
import Vapor
import Leaf

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
 // app.databases.use(.sqlite(.file("db_shop.sqlite")), as: .sqlite)
    
    
    let directoryConfig = DirectoryConfiguration.detect()
    print("\(directoryConfig.workingDirectory)")
    app.databases.use(.sqlite(.file("/Users/maximsafronov/Documents/Git/VaporApp/shop.sqlite")), as: .sqlite)
    // прописать путь до базы данных 
  //  app.databases.use(.sqlite(.file("shop.sqlite")), as: .sqlite)
    
    app.migrations.add(CreateUser())
    app.migrations.add(CreateBasket())
    app.migrations.add(CreateGood())
    app.migrations.add(CreateReview())
    
    try app.autoMigrate().wait()
    
    // register routes
    try routes(app)
}

