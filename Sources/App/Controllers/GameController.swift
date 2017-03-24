//
//  GameController.swift
//  scoket
//
//  Created by Valen on 21/03/2017.
//
//

import Vapor
import HTTP
import Fluent

final class GameController{
    
    static func endGameView(request: Request, scgame: SCGame)throws -> ResponseRepresentable{
        
        let scteamone: SCTeam? = try scgame.teamone()
        let scteamtwo: SCTeam? = try scgame.teamtwo()
        
        let parameters = try Node(node: [
            "teamone": try scteamone?.makeNode(),
            "teamtwo": try scteamtwo?.makeNode(),
            "game": try scgame.makeJSON()
            ])

        
        return try drop.view.make("endgame",parameters)
    }
    
    static func endGame(request: Request, scgame: SCGame)throws -> ResponseRepresentable{
        var game = scgame
        
        guard let pointsone = request.formURLEncoded?["tone"]?.int,
            let pointstwo = request.formURLEncoded?["ttwo"]?.int
            else {
                return "Mising points"
            }
        game.result1 = pointsone
        game.result2 = pointstwo
        game.ended = true
        
        var gr = pointsone
        var ls = pointstwo
        var grtusers: [SCUser]? = try game.teamone()?.users().all()
        var lssusers: [SCUser]? = try game.teamtwo()?.users().all()
        
        if(pointsone<pointstwo){
            gr = pointstwo
            ls = pointsone
            let aux = grtusers
            grtusers = lssusers
            lssusers = aux
        }
        
        for user in grtusers!{
            try user.upgradePoints(points: 10*(gr-ls))
        }
        for user in lssusers!{
            try user.upgradePoints(points: -5*(gr-ls))
        }
        
        try game.save()
        return Response(redirect: "/sc/games")
    }
    
    
    static func indexView(request: Request) throws -> ResponseRepresentable{
        var user: SCUser? = nil
        do {
            user = try request.auth.user() as? SCUser
        } catch { return Response(redirect: "/sc/login")}
        
        let team:SCTeam? = try user?.team().first()
        let games: [SCGame]? = try team?.games().all()
        
        let parameters = try Node(node: [
            "game": games?.makeJSON(),
            "user": user?.makeJSON()
            ])

        return try drop.view.make("games", parameters)
    }
}
