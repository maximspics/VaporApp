import Fluent
import FluentSQLiteDriver
import Vapor

func routes(_ app: Application) throws {
    
    let result = Results()
    
    app.get { req in
        return result.returnError(message: "Forbidden")
    }
    
    let authController = AuthController()
    app.post("auth", "register", use: authController.register)
    app.post("auth", "login", use: authController.login)
    app.post("auth", "get", use: authController.getUserData)
    app.post("auth", "change", use: authController.changeData)
    app.post("auth", "logout", use: authController.logout)
    
    app.get("catalog", ":action") { req -> String in
        if let action = req.parameters.get("action") {
            return Catalog().doAction(action: action, queryString: req.query)
        } else {
            return result.returnError(message: "You must specify method")
        }
    }
    
    app.get("reviews", ":action") { req -> String in
        if let action = req.parameters.get("action") {
            return Reviews().doAction(action: action, queryString: req.query)
        } else {
            return result.returnError(message: "You must specify method")
        }
    }
    
    app.get("basket", ":action") { req -> String in
        if let action = req.parameters.get("action") {
            return Basket().doAction(action: action, queryString: req.query)
        } else {
            return result.returnError(message: "You must specify method")
        }
    }
}
