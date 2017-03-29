//
//  Team.swift
//  scoket
//
//  Created by Valen on 21/03/2017.
//
//

import Vapor
import Fluent


final class Team: Model {
    var id: Node?
    
    var teamName: String
    var totalGames: Int
    var wins: Int
    var losses: Int
    
    init(teamName: String, totalGames: Int = 0, wins: Int = 0, losses: Int = 0) {
        self.teamName = teamName
        self.totalGames = totalGames
        self.wins = wins
        self.losses = losses
    }
    
    init (node: Node, in context: Context) throws {
        id = try node.extract("id")
        teamName = try node.extract("teamName")
        totalGames = try node.extract("totalGames")
        wins = try node.extract("wins")
        losses = try node.extract("losses")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "teamName": teamName,
            "totalGames": totalGames,
            "wins": wins,
            "losses": losses
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("teams"){team in
            team.id()
            team.string("teamName")
            team.integer("totalGames")
            team.integer("wins")
            team.integer("losses")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("teams")
    }
    
}

extension Team {
    func users() throws -> Children<User> {
        return children()
    }
    
    func games() throws -> Siblings<Game> {
        return try siblings()
    }
    
    func messages() throws -> Children<Message> {
        return children()
    }
}


