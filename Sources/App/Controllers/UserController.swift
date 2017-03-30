import Vapor
import HTTP
import Turnstile
import Fluent

final class UserController{
        
    static func indexView(request: Request) throws -> ResponseRepresentable {
        var user: User? = nil
        do {
            user = try request.auth.user() as? User
        } catch { return Response(redirect: "/sc/login")}
        
        var name: String? = nil
        var game: [Game]? = nil
        
        if let user = user {
            name = user.nickname
            game = try Game.query().filter("ended",false).all()
        }
        
        
        let parameters = try Node(node: [
            "user": user?.makeJSON(),
            "name": name,
            "game": game?.makeJSON()
            ])
        return try drop.view.make("index", parameters)
    }
    
    static func create(request: Request) throws -> ResponseRepresentable{
        var user = try request.scuser()
        try user.save()
        return user
    }
    
    static func registerView(request: Request) throws -> ResponseRepresentable{
        return try drop.view.make("register")
    }
    
    static func register(request: Request) throws -> ResponseRepresentable {
        guard let nickname = request.formURLEncoded?["nickname"]?.string,
            let password = request.formURLEncoded?["password"]?.string,
            let email = request.formURLEncoded?["email"]?.string
            else {
                return "Mising name, email or password"
        }
        
        _ = try User.register(nickname: nickname, email: email , pass: password)
        
        let credentials = UsernamePassword(username: nickname, password: password)
        try request.auth.login(credentials)
        
        return Response(redirect: "/sc")
    }
    
    static func loginView(request: Request) throws -> ResponseRepresentable {
        return try drop.view.make("login")
    }
    
    static func login(request: Request) throws -> ResponseRepresentable {
        guard let nickname = request.formURLEncoded?["nickname"]?.string,
            let password = request.formURLEncoded?["password"]?.string else {
                return "Missing name or password"
        }
        let credentials = UsernamePassword(username: nickname, password: password)
        do {
            try request.auth.login(credentials)
            return Response(redirect: "/sc")
        } catch let e as TurnstileError {
            return e.description
        }
    }
    
    static func logout(request: Request) throws -> ResponseRepresentable {
        try request.auth.logout()
        return Response(redirect: "/sc")
    }
    
    
    static func highscores(request: Request)throws -> ResponseRepresentable{
        
        var user: User? = nil
        do {
            user = try request.auth.user() as? User
        } catch { return Response(redirect: "/sc/login")}
        
        let users = try User.query().sort("score", Sort.Direction.descending).all()
        
        let parameters = try Node(node: [
            "users": users.makeJSON(),
            "user": user?.makeJSON()
            ])
        
        return try drop.view.make("highscores", parameters)
    }
    
}

extension Request {
    func scuser() throws -> User {
        guard let json = json else {throw Abort.badRequest}
        return try User(node: json)
    }
}
