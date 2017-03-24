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
        let sc = builder.grouped("sc","tourt")
        let create = sc.grouped("create")
        
        sc.get{ req in
            return try TourtnamentController.indexView(request: req)
        }
        
        create.get{ req in
            return try TourtnamentController.createTourView(request: req)
        }
        
        create.post{ req in
            return try TourtnamentController.createTour(request: req)
        }
        
        sc.get(SCTourtnament.self, "games"){req, tour in
            return try TourtnamentController.showGames(request: req, sctourt: tour)
        }
        
        sc.post(SCTourtnament.self, "add", SCTeam.self){req, tour, te in
            return try TourtnamentController.registerTeam(request: req, sctourt: tour, scteam: te)
        }
        
        sc.post(SCTourtnament.self, "remove", SCTeam.self){req, tour, te in
            return try TourtnamentController.removeTeam(request: req, sctourt: tour, scteam: te)
        }
        
        sc.get(SCTourtnament.self, "start"){req, tour in
            return try TourtnamentController.startTourtnament(request: req, sctourt: tour)
        }
    }
}
