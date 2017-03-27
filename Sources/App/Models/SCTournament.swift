//
//  SCTournament.swift
//  scoket
//
//  Created by Valen on 21/03/2017.
//
//

import Vapor
import Fluent

final class SCTournament: Model {
    var id: Node?
    
    var tourName: String
    var dateBeg: String
    var dateEnd: String
    var open: Bool
    
    init(tourName: String, dateBeg:String, dateEnd: String, open: Bool = true){
        self.tourName = tourName
        self.dateBeg = dateBeg
        self.dateEnd = dateEnd
        self.open = open
    }
    
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        
        tourName = try node.extract("tourName")
        dateBeg = try node.extract("dateBeg")
        dateEnd = try node.extract("dateEnd")
        open = try node.extract("open")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
                "id": id,
                "tourName": tourName,
                "dateBeg": dateBeg,
                "dateEnd": dateEnd,
                "open": open
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("sctournaments") {tour in
            tour.id()
            tour.string("tourName")
            tour.string("dateBeg")
            tour.string("dateEnd")
            tour.bool("open")
        }
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
}

