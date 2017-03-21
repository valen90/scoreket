//
//  SCGame.swift
//  scoket
//
//  Created by Valen on 17/03/2017.
//
//

import Vapor
import Fluent

final class SCGame: Model {
    var id: Node?
    
    var team1: Int
    var team2: Int
    var date: String
    var ended: Bool
    var result1: Int
    var result2: Int
    //var tourt: Node?
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        team1 = try node.extract("team1")
        team2 = try node.extract("team2")
        date = try node.extract("date")
        ended = try node.extract("ended")
        result1 = try node.extract("result1")
        result2 = try node.extract("result2")
        //tourt = try node.extract("tourt")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
                "id": id,
                "team1": team1,
                "team2": team2,
                "date": date,
                "ended": ended,
                "result1": result1,
                "result2": result2
                //"tourt": tourt
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("scgames") { games in
            games.id()
            games.int("team1")
            games.int("team2")
            games.string("date")
            games.bool("ended")
            games.int("result1")
            games.int("result2")
        }
    }
    
    func makeJSON() throws -> JSON {
        let node = try Node(node: [
            "id": id,
            "team1": try SCTeam.find(team1)?.makeJSON(),
            "team2": try SCTeam.find(team2)?.makeJSON(),
            "date": date,
            "ended": ended,
            "result1": result1,
            "result2": result2
            //"tourt": tourt
            ])
        return try JSON(node: node)
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("scgames")
    }
    
}

extension SCGame {
    func users() throws -> Siblings<SCTeam> {
        //let users: Siblings<SCUser> = try siblings()
        return try siblings()
    }
}

extension SCGame {
    func userone() throws -> SCUser? {
        return try parent(Node(team1), nil, SCUser.self).get()
    }
    func usertwo() throws -> SCUser? {
        return try parent(Node(team2), nil, SCUser.self).get()
    }
}
