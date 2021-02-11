import Fluent
import FluentSQLiteDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    
    app.databases.use(.sqlite(.file("/Users/maximsafronov/Documents/Git/GBShop/GBShop.sqlite")), as: .sqlite)
  //  app.databases.use(.sqlite(.file("GBShop.sqlite")), as: .sqlite)
    
    app.migrations.add(CreateUser())
    app.migrations.add(CreateBasket())
    app.migrations.add(CreateGood())
    app.migrations.add(CreateReview())
    
    try app.autoMigrate().wait()
    
    // register routes
    try routes(app)
}

