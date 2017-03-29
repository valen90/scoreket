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
    
    static func endGameView(request: Request, scgame: Game)throws -> ResponseRepresentable{
        
        let scteamOne: Team? = try scgame.teamone()
        let scteamTwo: Team? = try scgame.teamtwo()
        
        let parameters = try Node(node: [
            "teamone": try scteamOne?.makeNode(),
            "teamtwo": try scteamTwo?.makeNode(),
            "game": try scgame.makeJSON()
            ])

        
        return try drop.view.make("endgame",parameters)
    }
    
    static func endGame(request: Request, scgame: Game)throws -> ResponseRepresentable{
        
        guard let pointsone = request.formURLEncoded?["tone"]?.int,
            let pointstwo = request.formURLEncoded?["ttwo"]?.int
            else {
                return "Mising points"
            }
        var user: User? = nil
        do {
            user = try request.auth.user() as? User
        } catch { return Response(redirect: "/sc/login")}
        
        try GameHelper.createMessage(user: user!, game: scgame, pointsOne: pointsone, pointsTwo: pointstwo)
        return Response(redirect: "/sc/games")
    }
    
    static func acceptGame(request: Request, scmessage: Message) throws -> ResponseRepresentable{
        try GameHelper.updateScores(message: scmessage)
        var sctour = try scmessage.returnGame()?.tournament()
        let games: [Game] = try sctour!.games().all()
        let endgames: [Game] = try sctour!.games().filter("ended", true).all()
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
        var user: User? = nil
        do {
            user = try request.auth.user() as? User
        } catch { return Response(redirect: "/sc/login")}
        
        let team:Team? = try user?.team()?.first()
        let games: [Game]? = try team?.games().all()
        
        let parameters = try Node(node: [
            "game": games?.makeJSON(),
            "user": user?.makeJSON()
            ])

        return try drop.view.make("games", parameters)
    }
}
