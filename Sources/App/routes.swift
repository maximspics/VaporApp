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
    app.get("basket", "get", use: basketController.getBasket)
    app.get("basket", "add", use: basketController.addToBasket)
    app.get("basket", "remove", use: basketController.removeFromBasket)
    app.get("basket", "clear", use: basketController.clearBasket)
    app.get("basket", "pay", use: basketController.payOrder)
    
    let goodsController = GoodsController()
    app.post("good", "list", use: goodsController.list)
    app.post("good", "product", use: goodsController.product)
    
    let reviewController = ReviewController()
    app.get("review", "list", use: reviewController.list)
    app.post("review", "add", use: reviewController.add)
    app.get("review", "remove", use: reviewController.remove)
    app.get("review", "approve", use: reviewController.approve)
    
}
