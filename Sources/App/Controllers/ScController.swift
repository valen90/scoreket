import Vapor
import HTTP
import Turnstile

final class SCController{
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
        
        let user = try? request.auth.user() as! SCUser
        
        var name: String? = nil
        if let user = user {
            name = try user.nickname
        }
        
        let parameters = try Node(node: [
            "name": name,
            "authenticated": user != nil,
            "user": user?.makeNode()
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
    
    
}

extension Request {
    func scuser() throws -> SCUser {
        guard let json = json else {throw Abort.badRequest}
        return try SCUser(node: json)
    }
}
