//
//  SCTourtnament.swift
//  scoket
//
//  Created by Valen on 21/03/2017.
//
//

import Vapor
import Fluent

final class SCTourtnament: Model {
    var id: Node?
    
    var tourtName: String
    var dateBeg: String
    var dateEnd: String
    var open: Bool
    
    init(tourtName: String, dateBeg:String, dateEnd: String, open: Bool = true){
        self.tourtName = tourtName
        self.dateBeg = dateBeg
        self.dateEnd = dateEnd
        self.open = open
    }
    
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        
        tourtName = try node.extract("tourtName")
        dateBeg = try node.extract("dateBeg")
        dateEnd = try node.extract("dateEnd")
        open = try node.extract("open")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
                "id": id,
                "tourtName": tourtName,
                "dateBeg": dateBeg,
                "dateEnd": dateEnd,
                "open": open
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("sctourtnaments") {tourt in
            tourt.id()
            tourt.string("tourtName")
            tourt.string("dateBeg")
            tourt.string("dateEnd")
            tourt.bool("open")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("sctourtnaments")
    }
}

extension SCTourtnament {
    func games() throws -> Children<SCGame> {
        return children()
    }
    
    func teams() throws -> [SCTeam] {
        let teams: Siblings<SCTeam> = try siblings()
        return try teams.all()
    }
}

