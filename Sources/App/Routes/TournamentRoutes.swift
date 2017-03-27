//
//  TournamentRoutes.swift
//  scoket
//
//  Created by Valen on 24/03/2017.
//
//

import Vapor
import HTTP
import Routing

class TournamentRoutes: RouteCollection {
    typealias Wrapped = HTTP.Responder
    func build<B: RouteBuilder>(_ builder: B) where B.Value == Wrapped {
        let sc = builder.grouped("sc","tour")
        let create = sc.grouped("create")
        
        sc.get{ req in
            return try TournamentController.indexView(request: req)
        }
        
        create.get{ req in
            return try TournamentController.createTourView(request: req)
        }
        
        create.post{ req in
            return try TournamentController.createTour(request: req)
        }
        
        sc.get(SCTournament.self, "games"){req, tour in
            return try TournamentController.showGames(request: req, sctour: tour)
        }
        
        sc.post(SCTournament.self, "add", SCTeam.self){req, tour, te in
            return try TournamentController.registerTeam(request: req, sctour: tour, scteam: te)
        }
        
        sc.post(SCTournament.self, "remove", SCTeam.self){req, tour, te in
            return try TournamentController.removeTeam(request: req, sctour: tour, scteam: te)
        }
        
        sc.get(SCTournament.self, "start"){req, tour in
            return try TournamentController.startTournament(request: req, sctour: tour)
        }
    }
}
