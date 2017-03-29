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
        
        guard let pointsone = request.formURLEncoded?["tone"]?.int,
            let pointstwo = request.formURLEncoded?["ttwo"]?.int
            else {
                return "Mising points"
            }
        var user: SCUser? = nil
        do {
            user = try request.auth.user() as? SCUser
        } catch { return Response(redirect: "/sc/login")}
        
        try GameHelper.createMessage(user: user!, game: scgame, pointsOne: pointsone, pointsTwo: pointstwo)
        return Response(redirect: "/sc/games")
    }
    
    static func acceptGame(request: Request, scmessage: Message) throws -> ResponseRepresentable{
        try GameHelper.updateScores(message: scmessage)
        var sctour = try scmessage.returnGame()?.tournament()
        let games: [SCGame] = try sctour!.games().all()
        let endgames: [SCGame] = try sctour!.games().filter("ended", true).all()
        if games.count == endgames.count && games.count>0{
            sctour?.ended = true
            sctour?.winner = try TournamentHelper.calculateWinner(tour: sctour!)?.id?.int
        }
        try sctour?.save()
        
        return Response(redirect: "/sc/messages")
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
