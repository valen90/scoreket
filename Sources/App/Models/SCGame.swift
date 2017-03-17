//
//  SCGame.swift
//  scoket
//
//  Created by Valen on 17/03/2017.
//
//

import Vapor

final class SCGame: Model {
    var id: Node?
    
    var user1: Node?
    var user2: Node?
    var date: String
    var ended: Bool
    var result1: Int
    var result2: Int
    //var tourt: Node?
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        user1 = try node.extract("user1")
        user2 = try node.extract("user2")
        date = try node.extract("date")
        ended = try node.extract("ended")
        result1 = try node.extract("result1")
        result2 = try node.extract("result2")
        //tourt = try node.extract("tourt")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "user1": user1,
            "user2": user2,
            "date": date,
            "ended": ended,
            "result1": result1,
            "result2": result2
            //"tourt": tourt
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("games") { games in
            games.id()
            games.int("user1")
            games.int("user1")
            games.string("date")
            games.bool("ended")
            games.int("result1")
            games.int("result2")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("acronyms")
    }
    
}

extension SCGame {
    func userone() throws -> SCUser? {
        return try parent(user1, nil, SCUser.self).get()
    }
    func usertwo() throws -> SCUser? {
        return try parent(user2, nil, SCUser.self).get()
    }
}
