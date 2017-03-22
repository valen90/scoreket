import Vapor
import HTTP
import Turnstile
import Fluent

final class UserController{
    func addRoutes(drop: Droplet){
        let sc = drop.grouped("sc")
        sc.get(handler: indexView)
        sc.post(handler: create)
        sc.get("register", handler: registerView)
        sc.post("register", handler: register)
        sc.get("login", handler: loginView)
        sc.post("login", handler: login)
        sc.get("logout", handler: logout)
    }
    
    func indexView(request: Request) throws -> ResponseRepresentable {
        var user: SCUser? = nil
        do {
            user = try request.auth.user() as? SCUser
        } catch { return Response(redirect: "/sc/login")}
        
        var name: String? = nil
        var game: [SCGame]? = nil
        
        if let user = user {
            name = user.nickname
            game = try SCGame.query().filter("ended",false).all()
        }
        
        
        let parameters = try Node(node: [
            "name": name,
            "game": game?.makeJSON(),
            "authenticated": user != nil,
            "user": user?.makeJSON()
            ])
        return try drop.view.make("index", parameters)
    }
    
    func create(request: Request) throws -> ResponseRepresentable{
        var user = try request.scuser()
        try user.save()
        return user
    }
    
    func registerView(request: Request) throws -> ResponseRepresentable{
        return try drop.view.make("register")
    }
    
    func register(request: Request) throws -> ResponseRepresentable {
        guard let nickname = request.formURLEncoded?["nickname"]?.string,
            let password = request.formURLEncoded?["password"]?.string,
            let email = request.formURLEncoded?["email"]?.string
            else {
                return "Mising name, email or password"
        }
        
        _ = try SCUser.register(nickname: nickname, email: email , pass: password)
        
        let credentials = UsernamePassword(username: nickname, password: password)
        try request.auth.login(credentials)
        
        return Response(redirect: "/sc")
    }
    
    func loginView(request: Request) throws -> ResponseRepresentable {
        return try drop.view.make("login")
    }
    
    func login(request: Request) throws -> ResponseRepresentable {
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
    
    func logout(request: Request) throws -> ResponseRepresentable {
        try request.auth.logout()
        return Response(redirect: "/sc")
    }
    
    func joinGame(request: Request, scuser: SCUser, scgame: SCGame) throws -> ResponseRepresentable {
        var pivot = Pivot<SCUser, SCGame> (scuser,scgame)
        try pivot.save()
        return scuser
    }
    
    
    func gamesIndex (request: Request, scteam: SCTeam) throws -> ResponseRepresentable{
        let games = try scteam.games()
        return try JSON(node: games.makeNode())
    }
    
}

extension Request {
    func scuser() throws -> SCUser {
        guard let json = json else {throw Abort.badRequest}
        return try SCUser(node: json)
    }
}
