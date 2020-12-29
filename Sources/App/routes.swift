import Fluent
import FluentSQLiteDriver
import Vapor

func routes(_ app: Application) throws {
    
    let result = Results()
    
    app.get { req in
        return result.returnError("Forbidden")
    }
    
    let authController = AuthController()
    app.post("auth", "register", use: authController.register)
    app.post("auth", "login", use: authController.login)
    app.post("auth", "get", use: authController.getUserData)
    app.post("auth", "change", use: authController.changeData)
    app.post("auth", "logout", use: authController.logout)
    
    let basketController = BasketController()
    app.post("basket", "get", use: basketController.getBasket)
    app.post("basket", "add", use: basketController.addToBasket)
    app.post("basket", "remove", use: basketController.removeFromBasket)
    app.post("basket", "pay", use: basketController.payOrder)
    
    let goodsController = GoodsController()
    app.post("good", "list", use: goodsController.list)
    app.post("good", "product", use: goodsController.product)
    
    let reviewController = ReviewController()
    app.post("review", "list", use: reviewController.list)
    app.post("review", "add", use: reviewController.add)
    app.post("review", "remove", use: reviewController.remove)
    app.post("review", "approve", use: reviewController.approve)
    
    /*
    app.get("catalog", ":action") { req -> EventLoopFuture<String> in
        if let action = req.parameters.get("action") {
            return Catalog().doAction(action: action, queryString: req.query)
        } else {
            return result.error(message: "You must specify method")
        }
    }
    
    app.get("reviews", ":action") { req -> EventLoopFuture<String> in
        if let action = req.parameters.get("action") {
            return Reviews().doAction(action: action, queryString: req.query)
        } else {
            return result.error(message: "You must specify method")
        }
    }
    
    app.get("basket", ":action") { req -> EventLoopFuture<String> in
        if let action = req.parameters.get("action") {
            return Basket().doAction(action: action, queryString: req.query)
        } else {
            return result.error(message: "You must specify method")
        }
    }*/
}
