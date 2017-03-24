//
//  TeamRoutes.swift
//  scoket
//
//  Created by Valen on 24/03/2017.
//
//

import Vapor
import HTTP
import Routing

class TeamRoutes: RouteCollection {
    typealias Wrapped = HTTP.Responder
    func build<B: RouteBuilder>(_ builder: B) where B.Value == Wrapped {
        let sc = builder.grouped("sc","team")
        
        sc.get{ req in
            return try TeamController.teamsView(request: req)
        }
        
        sc.post{ req in
            return try TeamController.create(request: req)
        }
        
        sc.get(SCTeam.self, "info"){ req, te in
            return try TeamController.teamInfo(request: req, scteam: te)
        }
        
        sc.get("create"){ req in
            return try TeamController.createView(request: req)
        }
        
        sc.get(SCUser.self, "leave"){ req, us in
            return try TeamController.leaveTeam(request: req, scuser: us)
        }
        
        sc.get(SCTeam.self, "games"){ req, te in
            return try TeamController.gamesIndex(request: req, scteam: te)
        }
        
        sc.post(SCTeam.self, "join", SCUser.self){ req, te, us in
            return try TeamController.joinTeam(request: req, scteam: te, scuser: us)
        }
        
        sc.get(SCTeam.self, "users"){ req, te in
            return try TeamController.userIndex(request: req, scteam: te)
        }
    }
}
