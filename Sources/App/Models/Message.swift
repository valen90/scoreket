//
//  Message.swift
//  scoket
//
//  Created by Valen on 28/03/2017.
//
//

import Vapor
import Fluent

final class Message: Model {
    var id: Node?
    var game: Int
    var resultOne: Int
    var resultTwo: Int
    var scteam_id: Int
    
    init(game: Int, resultOne: Int, resultTwo: Int, scteam_id: Int)throws{
        self.game = game
        self.resultOne = resultOne
        self.resultTwo = resultTwo
        self.scteam_id = scteam_id
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        game = try node.extract("game")
        resultOne = try node.extract("resultOne")
        resultTwo = try node.extract("resultTwo")
        scteam_id = try node.extract("scteam_id")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "game": game,
            "resultOne": resultOne,
            "resultTwo": resultTwo,
            "scteam_id": scteam_id
            ])
    }
    
    func makeJSON() throws -> JSON {
        return try JSON(node: [
                "id":id,
                "game": try SCGame.find(Node(game))?.makeJSON(),
                "resultOne": resultOne,
                "resultTwo": resultTwo,
                "scteam_id": try SCTeam.find(Node(scteam_id))?.makeJSON()
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("messages"){ message in
            message.id()
            message.integer("game", signed: false)
            message.int("resultOne")
            message.int("resultTwo")
            message.integer("scteam_id", signed: false)
        }
        
        try database.foreign(
            parentTable: "scteams",
            parentPrimaryKey: "id",
            childTable: "messages",
            childForeignKey: "scteam_id")
        
        try database.foreign(
            parentTable: "scgames",
            parentPrimaryKey: "id",
            childTable: "messages",
            childForeignKey: "game")

    }
    
    static func revert(_ database: Database) throws {
        try database.delete("messages")
    }
    
}

extension Message {
    func returnGame() throws -> SCGame? {
        return try parent(Node(self.game),nil,SCGame.self).get()
    }
    
    func returnTeam() throws -> SCTeam? {
        return try parent(Node(self.scteam_id),nil,SCTeam.self).get()
    }
}

