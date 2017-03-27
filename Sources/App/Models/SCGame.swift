//
//  SCGame.swift
//  scoket
//
//  Created by Valen on 17/03/2017.
//
//

import Vapor
import Fluent
import Foundation

final class SCGame: Model {
    var id: Node?
    
    var team1: Int
    var team2: Int
    var date: Date
    var ended: Bool
    var result1: Int?
    var result2: Int?
    var sctournament_id: Int
    
    init(team1: Int, team2: Int, date: Date, sctournament_id: Int ,result1: Int?,result2: Int?, ended: Bool = false) throws {
        self.team1 = team1
        self.team2 = team2
        self.date = date
        self.ended = ended
        self.result1 = result1
        self.result2 = result2
        self.sctournament_id = sctournament_id
        
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        team1 = try node.extract("team1")
        team2 = try node.extract("team2")
        date = try node.extract("date", transform: SCGame.dateFromString)!
        ended = try node.extract("ended")
        result1 = try node.extract("result1")
        result2 = try node.extract("result2")
        sctournament_id = try node.extract("sctournament_id")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
                "id": id,
                "team1": team1,
                "team2": team2,
                "date": SCGame.dateToString(date),
                "ended": ended,
                "result1": result1,
                "result2": result2,
                "sctournament_id": sctournament_id
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("scgames") { games in
            games.id()
            games.int("team1")
            games.int("team2")
            games.custom("date",type: "TIMESTAMP")
            games.bool("ended")
            games.int("result1", optional: true)
            games.int("result2", optional: true)
            games.int("sctournament_id")
        }
    }
    
    func makeJSON() throws -> JSON {
        let node = try Node(node: [
            "id": id,
            "team1": try SCTeam.find(team1)?.makeJSON(),
            "team2": try SCTeam.find(team2)?.makeJSON(),
            "date": SCGame.dateToString(date),
            "ended": ended,
            "result1": result1,
            "result2": result2,
            "sctournament_id": try SCTournament.find(sctournament_id)?.makeJSON()
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
    
    func tournament() throws -> SCTournament? {
        return try parent(Node(sctournament_id), nil, SCTournament.self).get()
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

extension SCGame {
    static func dateFromString(_ dateAsString: String?) -> Date? {
        guard let string = dateAsString else { return nil }
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let val = dateformatter.date(from: string)
        return val
    }
    
    static func dateToString(_ dateIn: Date?) -> String? {
        guard let date = dateIn else { return nil }
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let val = dateformatter.string(from: date)
        return val
    }
}
