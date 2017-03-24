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
    var sctourtnament_id: Int
    
    init(team1: Int, team2: Int, date: String, sctourtnament_id: Int ,ended: Bool = false,result1: Int = 0,result2: Int = 0) throws {
        self.team1 = team1
        self.team2 = team2
        self.date = date
        self.ended = ended
        self.result1 = result1
        self.result2 = result2
        self.sctourtnament_id = sctourtnament_id
        
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        team1 = try node.extract("team1")
        team2 = try node.extract("team2")
        date = try node.extract("date")
        ended = try node.extract("ended")
        result1 = try node.extract("result1")
        result2 = try node.extract("result2")
        sctourtnament_id = try node.extract("sctourtnament_id")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
                "id": id,
                "team1": team1,
                "team2": team2,
                "date": date,
                "ended": ended,
                "result1": result1,
                "result2": result2,
                "sctourtnament_id": sctourtnament_id
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
            games.int("sctourtnament_id")
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
            "result2": result2,
            "sctourtnament_id": try SCTourtnament.find(sctourtnament_id)?.makeJSON()
            ])
        return try JSON(node: node)
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("scgames")
    }
    
}

extension SCGame {
    func teams() throws -> Siblings<SCTeam> {
        //let users: Siblings<SCUser> = try siblings()
        return try siblings()
    }
    
    func tourtnament() throws -> SCTourtnament? {
        return try parent(Node(sctourtnament_id), nil, SCTourtnament.self).get()
    }
    
    func deletegame()throws {
        try SCGame.find(self.id!)?.delete()
    }
}

extension SCGame {
    func teamone() throws -> SCTeam? {
        return try parent(Node(team1), nil, SCTeam.self).get()
    }
    func teamtwo() throws -> SCTeam? {
        return try parent(Node(team2), nil, SCTeam.self).get()
    }
}
