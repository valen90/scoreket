import Vapor
import HTTP
import Routing

class UserRoutes: RouteCollection {
    typealias Wrapped = HTTP.Responder
    func build<B: RouteBuilder>(_ builder: B) where B.Value == Wrapped {
        let sc = builder.grouped("sc")

        sc.get { request in
            return try UserController.indexView(request: request)
        }
        sc.post { req in
            return try UserController.create(request: req)
        }
        sc.get("register") { request in
            return try UserController.registerView(request: request)
        }
        sc.post("register") { request in
            return try UserController.register(request: request)
        }
        sc.get("login") { request in
            return try UserController.loginView(request: request)
        }
        sc.post("login") { request in
            return try UserController.login(request: request)
        }
        sc.get("logout") { request in
            return try UserController.logout(request: request)
        }
        sc.get("highscores") { request in
            return try UserController.highscores(request: request)
        }
        
    }
}
