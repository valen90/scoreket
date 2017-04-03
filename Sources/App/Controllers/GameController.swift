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
    
    static func endGameView(request: Request, game: Game)throws -> ResponseRepresentable {
        return try drop.view.make("endgame", game.makeJSON())
    }
    
    static func endGame(request: Request, scgame: Game)throws -> ResponseRepresentable{
        
        guard let pointsone = request.formURLEncoded?["tone"]?.string,
            let pointstwo = request.formURLEncoded?["ttwo"]?.string
            else {
                return "Mising points"
            }
        let pointsOne: Valid<DateValidator> = try pointsone.validated()
        let pointsTwo: Valid<DateValidator> = try pointstwo.validated()
        var user: User? = nil
        do {
            user = try request.auth.user() as? User
        } catch { return Response(redirect: "/sc/login")}   
        
        try GameHelper.createMessage(user: user!, game: scgame, pointsOne: pointsOne.value.int!, pointsTwo: pointsTwo.value.int!)
        return Response(redirect: "/sc/games")
    }
    
    static func acceptGame(request: Request, scmessage: Message) throws -> ResponseRepresentable{
        try GameHelper.updateScores(message: scmessage)
    
        var sctour: Tournament = try scmessage.returnGame().tournament()
        
        if try sctour.games().filter("ended", false).count() == 0 {
            sctour.ended = true
            sctour.winner = try TournamentHelper.calculateWinner(tour: sctour)
            try sctour.save()
        }
        
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
