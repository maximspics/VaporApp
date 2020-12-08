import Fluent
import Vapor

func routes(_ app: Application) throws {
    let result = Results()
    
    app.get { req in
        return result.returnError(message: "Forbidden")
    }
    
    app.get("auth", ":action") { req -> String in
        if let action = req.parameters.get("action") {
            return Auth().doAction(action: action, queryString: req.query)
        } else {
            return result.returnError(message: "You must specify method")
        }
    }
    
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
    
    let controller = AuthController()
    app.post("test", "register", use: controller.register)
    
}
