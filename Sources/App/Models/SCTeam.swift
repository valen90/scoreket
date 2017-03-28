//
//  SCTeam.swift
//  scoket
//
//  Created by Valen on 21/03/2017.
//
//

import Vapor
import Fluent


final class SCTeam: Model {
    var id: Node?
    
    var teamName: String
    
    init(teamName: String) {
        self.teamName = teamName
    }
    
    init (node: Node, in context: Context) throws {
        id = try node.extract("id")
        teamName = try node.extract("teamName")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "teamName": teamName,
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("scteams"){team in
            team.id()
            team.string("teamName")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("scteams")
    }
    
}

extension SCTeam {
    func users() throws -> Children<SCUser> {
        return children()
    }
    
    func games() throws -> Siblings<SCGame> {
        return try siblings()
    }
    
    func messages() throws -> Children<Message> {
        return children()
    }
}


