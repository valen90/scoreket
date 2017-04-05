//
//  Game.swift
//  scoket
//
//  Created by Valen on 17/03/2017.
//
//

import Vapor
import Fluent
import Foundation
import Sugar

final class Game: Model {
    var id: Node?
    
    var team1: Int
    var team2: Int
    var date: Date
    var ended: Bool
    var result1: Int?
    var result2: Int?
    var sctournament_id: Int
    var winner: Int?
    
    init(team1: Int, team2: Int, date: Date, sctournament_id: Int ,result1: Int?,result2: Int?, ended: Bool = false, winner: Int? = nil) throws {
        self.team1 = team1
        self.team2 = team2
        self.date = date
        self.ended = ended
        self.result1 = result1
        self.result2 = result2
        self.sctournament_id = sctournament_id
        self.winner = winner
        
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        team1 = try node.extract("team1")
        team2 = try node.extract("team2")
        date = try node.extract("date", transform: GameHelper.dateFromString)!
        ended = try node.extract("ended")
        result1 = try node.extract("result1")
        result2 = try node.extract("result2")
        sctournament_id = try node.extract("tournament_id")
        winner = try node.extract("winner")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
                "id": id,
                "team1": team1,
                "team2": team2,
                "date": GameHelper.dateToString(date),
                "ended": ended,
                "result1": result1,
                "result2": result2,
                "tournament_id": sctournament_id,
                "winner": winner
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("games") { games in
            games.id()
            games.integer("team1", signed: false)
            games.integer("team2", signed: false)
            games.custom("date",type: "TIMESTAMP")
            games.bool("ended")
            games.int("result1", optional: true)
            games.int("result2", optional: true)
            games.integer("tournament_id", signed: false)
            games.integer("winner", signed: false, optional: true)
        }
        
        try database.foreign(
            parentTable: "teams",
            parentPrimaryKey: "id",
            childTable: "games",
            childForeignKey: "team1")
        
        try database.foreign(
            parentTable: "teams",
            parentPrimaryKey: "id",
            childTable: "games",
            childForeignKey: "team2")
        
        try database.foreign(
            parentTable: "teams",
            parentPrimaryKey: "id",
            childTable: "games",
            childForeignKey: "winner")
        
        try database.foreign(
            parentTable: "tournaments",
            parentPrimaryKey: "id",
            childTable: "games",
            childForeignKey: "tournament_id")
        
    }
    
    func makeJSON() throws -> JSON {
        var winnerTeam: Team? = nil
        if winnerTeam != nil {
            winnerTeam = try Team.find(winner!)
        }
        let node = try Node(node: [
            "id": id,
            "team1": try Team.find(team1)?.makeJSON(),
            "team2": try Team.find(team2)?.makeJSON(),
            "date": GameHelper.dateToString(date),
            "ended": ended,
            "result1": result1,
            "result2": result2,
            "tournament_id": try Tournament.find(sctournament_id)?.makeJSON(),
            "winner": winnerTeam?.makeJSON()
            ])
        return try JSON(node: node)
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("games")
    }
    
}

extension Game {
    func teams() throws -> Siblings<Team> {
        return try siblings()
    }
    
    func tournament() throws -> Tournament {
        return try parent(Node(sctournament_id), nil, Tournament.self).get()!
    }
    
    func deletegame()throws {
        try Game.find(self.id!)?.delete()
    }
}

extension Game {
    func teamone() throws -> Team? {
        return try parent(Node(team1), nil, Team.self).get()
    }
    func teamtwo() throws -> Team? {
        return try parent(Node(team2), nil, Team.self).get()
    }
    func getWinner() throws -> Team? {
        return try parent(Node(winner!), nil, Team.self).get()
    }
}

