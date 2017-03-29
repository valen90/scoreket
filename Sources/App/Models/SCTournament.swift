//
//  SCTournament.swift
//  scoket
//
//  Created by Valen on 21/03/2017.
//
//

import Vapor
import Fluent
import Foundation

final class SCTournament: Model {
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
        dateBeg = try node.extract("dateBeg", transform: SCGame.dateFromString)
        dateEnd = try node.extract("dateEnd", transform: SCGame.dateFromString)
        open = try node.extract("open")
        ended = try node.extract("ended")
        winner = try node.extract("winner")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
                "id": id,
                "tourName": tourName,
                "dateBeg": SCGame.dateToString(dateBeg),
                "dateEnd": SCGame.dateToString(dateEnd),
                "open": open,
                "ended": ended,
                "winner": winner
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("sctournaments") {tour in
            tour.id()
            tour.string("tourName")
            tour.custom("dateBeg", type: "DATETIME", optional: true)
            tour.custom("dateEnd", type: "DATETIME", optional: true)
            tour.bool("open")
            tour.bool("ended")
            tour.integer("winner", signed: false, optional: true)
        }
        
        try database.foreign(
            parentTable: "scteams",
            parentPrimaryKey: "id",
            childTable: "sctournaments",
            childForeignKey: "winner")
        
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("sctournaments")
    }
}

extension SCTournament {
    func games() throws -> Children<SCGame> {
        return children()
    }
    
    func teams() throws -> [SCTeam] {
        let teams: Siblings<SCTeam> = try siblings()
        return try teams.all()
    }
    
    func getWinner() throws -> SCTeam? {
        return try parent(Node(self.winner!),nil,SCTeam.self).get()
    }
}

