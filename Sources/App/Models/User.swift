//
//  SCUser.swift
//  scoket
//
//  Created by Valen on 16/03/2017.
//
//

import Vapor
import Fluent
import Turnstile
import TurnstileCrypto
import Auth
import Sugar

final class User: Model, Auth.User{
    
    var id: Node?
    var nickname: String
    var email: String
    var password: String
    var score: Int
    var scteam_id: Int?
    private var admin: Bool = false
    
    init(nickname: String, email: String, password: String, score: Int = 0, scteam_id: Int? = nil) {
        self.nickname = nickname
        self.email = email
        self.password = BCrypt.hash(password: password)
        self.score = score
        self.scteam_id = scteam_id
    }
    
    init (node: Node, in context: Context) throws {
        id = try node.extract("id")
        nickname = try node.extract("nickname")
        email = try node.extract("email")
        password = try node.extract("password")
        score = try node.extract("score")
        scteam_id = try node.extract("team_id")
        admin = try node.extract("admin")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "nickname": nickname,
            "email": email,
            "password": password,
            "score": score,
            "team_id": scteam_id,
            "admin": admin
            ])
    }
    
    func makeJSON() throws -> JSON {
        var team: Team? = nil
        if scteam_id != nil {
            team = try Team.find(scteam_id!)
        }
        let node = try Node(node: [
            "id": id,
            "nickname": nickname,
            "email": email,
            "password": password,
            "score": score,
            "team_id": team?.makeNode(),
            "admin": admin
            ])
        return try JSON(node: node)
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("users"){users in
            users.id()
            users.string("nickname")
            users.string("email")
            users.string("password")
            users.int("score")
            users.integer("team_id", signed: false, optional: true)
            users.bool("admin")
        }
        try database.foreign(
            parentTable: "teams",
            parentPrimaryKey: "id",
            childTable: "users",
            childForeignKey: "team_id")
        
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("users")
    }
    
    static func register(nickname: String, email: String, pass: String) throws -> App.User{
        var newUser = App.User(nickname: nickname, email: email, password: pass)
        if try User.query().filter("nickname", newUser.nickname).first() == nil{
            try newUser.save()
            return newUser
        }else {
            throw AccountTakenError()
        }
    }
}

extension App.User {
    func team() throws -> Parent<Team>? {
        var node: Parent<Team>? = nil
        if scteam_id != nil {
            node = try parent(Node(scteam_id!))
        }
        return node
    }
}

extension App.User: Authenticator {
    static func authenticate(credentials: Credentials) throws -> Auth.User {
        var user: App.User?
        
        switch credentials{
        case let credentials as UsernamePassword:
            let fetchedUser = try User.query()
                .filter("nickname", credentials.username)
                .first()
            if let password = fetchedUser?.password,
                password != "",
                (try? BCrypt.verify(password: credentials.password, matchesHash: password)) == true{
                user = fetchedUser
            }
        case let credentials as Identifier:
            user = try User.find(credentials.id)
        default:
            throw UnsupportedCredentialsError()
        }
        if let user = user {
            return user
        }else {
            throw IncorrectCredentialsError()
        }
    }
    
    static func register(credentials: Credentials) throws -> Auth.User {
        throw Abort.badRequest
    }
}
