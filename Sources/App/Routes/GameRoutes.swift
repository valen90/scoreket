//
//  GameRoutes.swift
//  scoket
//
//  Created by Valen on 24/03/2017.
//
//

import Vapor
import HTTP
import Routing

class GameRoutes: RouteCollection {
    typealias Wrapped = HTTP.Responder
    func build<B: RouteBuilder>(_ builder: B) where B.Value == Wrapped {
        let sc = builder.grouped("sc","games")
        let end = sc.grouped("end")
        
        sc.get{ req in
            return try GameController.indexView(request: req)
        }
        
        sc.get("accept",Message.self) { req, mes in
            return try GameController.acceptGame(request: req,scmessage: mes )
        }
        
        sc.get("decline",Message.self) { req, mes in
            return try GameController.declineGame(request: req,scmessage: mes )
        }
        
        end.get(Game.self){ req, game in
            return try GameController.endGameView(request: req, scgame: game)
        }
        
        end.post(Game.self){ req, game in
            return try GameController.endGame(request: req, scgame: game)
        }
    }
}
