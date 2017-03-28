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
        //var game = scgame
        
        guard let pointsone = request.formURLEncoded?["tone"]?.int,
            let pointstwo = request.formURLEncoded?["ttwo"]?.int
            else {
                return "Mising points"
            }
        //game.result1 = pointsone
        //game.result2 = pointstwo
        //game.ended = true
        
        /*
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
        */
        var user: SCUser? = nil
        do {
            user = try request.auth.user() as? SCUser
        } catch { return Response(redirect: "/sc/login")}
        
        let te = try user?.team()?.first()
        var mesteam: SCTeam
        if try scgame.teamone()?.id == te?.id {
            mesteam = try scgame.teamtwo()!
        }else {
            mesteam = try scgame.teamone()!
        }
        let gameInMessage: Message? = try Message.query().filter("game",(scgame.id?.int)!).first()
        if gameInMessage == nil{
            var mes = try Message(game: (scgame.id?.int)!, resultOne: pointsone, resultTwo: pointstwo, scteam_id: (mesteam.id?.int)!)
            try mes.save()
        }
        return Response(redirect: "/sc/games")
    }
    
    static func acceptGame(request: Request, scmessage: Message) throws -> ResponseRepresentable{
        var scGame: SCGame = try scmessage.returnGame()!
        
        scGame.result1 = scmessage.resultOne
        scGame.result2 = scmessage.resultTwo
        
        var gr = scmessage.resultOne
        var ls = scmessage.resultTwo
        var grtusers: [SCUser]? = try scGame.teamone()?.users().all()
        var lssusers: [SCUser]? = try scGame.teamtwo()?.users().all()
         
        if(scmessage.resultOne<scmessage.resultTwo){
            gr = scmessage.resultTwo
            ls = scmessage.resultOne
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
        scGame.ended = true
        try scmessage.delete()
        try scGame.save()
        

        return Response(redirect: "/sc/games")
    }
    
    static func declineGame(request: Request, scmessage: Message) throws -> ResponseRepresentable {
        try scmessage.delete()
        return Response(redirect: "/sc/messages")
    }
    
    static func indexView(request: Request) throws -> ResponseRepresentable{
        var user: SCUser? = nil
        do {
            user = try request.auth.user() as? SCUser
        } catch { return Response(redirect: "/sc/login")}
        
        let team:SCTeam? = try user?.team()?.first()
        let games: [SCGame]? = try team?.games().all()
        
        let parameters = try Node(node: [
            "game": games?.makeJSON(),
            "user": user?.makeJSON()
            ])

        return try drop.view.make("games", parameters)
    }
}
