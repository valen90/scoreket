//
//  Tournament.swift
//  scoket
//
//  Created by Valen on 21/03/2017.
//
//

import Vapor
import Fluent
import Foundation

final class Tournament: Model {
    var id: Node?
    
    var tourName: String
    var dateBeg: Date?
    var dateEnd: Date?
    var open: Bool
    var ended: Bool
    var winner: Int?
    
    init(tourName: String, dateBeg:Date?, dateEnd: Date?, open: Bool = true, ended: Bool = false){
        self.tourName = tourName
        self.dateBeg = dateBeg
        self.dateEnd = dateEnd
        self.open = open
        self.ended = ended
        self.winner = nil
    }
    
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        
        tourName = try node.extract("tourName")
        dateBeg = try node.extract("dateBeg", transform: GameHelper.dateFromString)
        dateEnd = try node.extract("dateEnd", transform: GameHelper.dateFromString)
        open = try node.extract("open")
        ended = try node.extract("ended")
        winner = try node.extract("winner")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
                "id": id,
                "tourName": tourName,
                "dateBeg": GameHelper.dateToString(dateBeg),
                "dateEnd": GameHelper.dateToString(dateEnd),
                "open": open,
                "ended": ended,
                "winner": winner
            ])
    }
    
    func makeJSON() throws -> JSON {
        var winnerTeam: Team? = nil
        if winnerTeam != nil {
            winnerTeam = try Team.find(winner!)
        }
        return try JSON(node: [
            "id": id,
            "tourName": tourName,
            "dateBeg": GameHelper.dateToString(dateBeg),
            "dateEnd": GameHelper.dateToString(dateEnd),
            "open": open,
            "ended": ended,
            "winner": try winnerTeam?.makeJSON()
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("tournaments") {tour in
            tour.id()
            tour.string("tourName")
            tour.custom("dateBeg", type: "DATETIME", optional: true)
            tour.custom("dateEnd", type: "DATETIME", optional: true)
            tour.bool("open")
            tour.bool("ended")
            tour.integer("winner", signed: false, optional: true)
        }
        
        try database.foreign(
            parentTable: "teams",
            parentPrimaryKey: "id",
            childTable: "tournaments",
            childForeignKey: "winner")
        
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("tournaments")
    }
}

extension Tournament {
    func games() throws -> Children<Game> {
        return children()
    }
    
    func teams() throws -> [Team] {
        let teams: Siblings<Team> = try siblings()
        return try teams.all()
    }
    
    func getWinner() throws -> Team? {
        return try parent(Node(self.winner!),nil,Team.self).get()
    }
}

