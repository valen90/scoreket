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


final class SCUser: Model, User{
    var exist: Bool = false
    
    var id: Node?
    var nickname: String
    var email: String
    var password: String
    var score: Int
    var scteam_id: Int
    
    init(nickname: String, email: String, password: String, score: Int = 0, scteam_id: Int = 0) {
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
        scteam_id = try node.extract("scteam_id")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "nickname": nickname,
            "email": email,
            "password": password,
            "score": score,
            "scteam_id": scteam_id
            ])
    }
    
    func makeJSON() throws -> JSON {
        let node = try Node(node: [
            "id": id,
            "nickname": nickname,
            "email": email,
            "password": password,
            "score": score,
            "scteam_id": try SCTeam.find(scteam_id)?.makeJSON()
            ])
        return try JSON(node: node)
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("scusers"){users in
            users.id()
            users.string("nickname")
            users.string("email")
            users.string("password")
            users.int("score")
            users.int("scteam_id")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("scusers")
    }
    
    static func register(nickname: String, email: String, pass: String) throws -> SCUser{
        var newUser = SCUser(nickname: nickname, email: email, password: pass)
        if try SCUser.query().filter("nickname", newUser.nickname).first() == nil{
            try newUser.save()
            return newUser
        }else {
            throw AccountTakenError()
        }
        
    }
    
    
}

extension SCUser {
    func team() throws -> Parent<SCTeam> {
        return try parent(Node(scteam_id))
    }
    
    
}

extension SCUser: Authenticator {
    static func authenticate(credentials: Credentials) throws -> User {
        var user: SCUser?
        
        switch credentials{
        case let credentials as UsernamePassword:
            let fetchedUser = try SCUser.query()
                .filter("nickname", credentials.username)
                .first()
            if let password = fetchedUser?.password,
                password != "",
                (try? BCrypt.verify(password: credentials.password, matchesHash: password)) == true{
                user = fetchedUser
            }
        case let credentials as Identifier:
            user = try SCUser.find(credentials.id)
        default:
            throw UnsupportedCredentialsError()
        }
        if let user = user {
            return user
        }else {
            throw IncorrectCredentialsError()
        }
    }
    
    static func register(credentials: Credentials) throws -> User {
        throw Abort.badRequest
    }
}
