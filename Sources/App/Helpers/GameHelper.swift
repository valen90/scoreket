//
//  GameHelper.swift
//  scoket
//
//  Created by Valen on 29/03/2017.
//
//

import Vapor
import Fluent

final class GameHelper{
    private static let multPointsWinner = 10
    private static let multPointsLosers = -5
    
    static func updateScores(message: Message)throws {
        var scGame: Game = try message.returnGame()
        scGame.result1 = message.resultOne
        scGame.result2 = message.resultTwo
        var teamW = try scGame.teamone()
        var teamL = try scGame.teamtwo()
        
        var gr = message.resultOne
        var ls = message.resultTwo
        var grtusers: [User]? = try scGame.teamone()?.users().all()
        var lssusers: [User]? = try scGame.teamtwo()?.users().all()
        
        if(message.resultOne<message.resultTwo){
            gr = message.resultTwo
            ls = message.resultOne
            let userAux = grtusers
            grtusers = lssusers
            lssusers = userAux
            let teamAux = teamW
            teamW = teamL
            teamL = teamAux
        }
        teamW?.wins += 1
        teamL?.losses += 1
        teamW?.totalGames += 1
        teamL?.totalGames += 1
        scGame.winner = teamW?.id?.int
        try teamW?.save()
        try teamL?.save()
        
        try GameHelper.addPoints(winners: grtusers!, losers: lssusers!, dif: (gr-ls))
        
        scGame.ended = true
        scGame.winner = teamW?.id?.int
        try message.delete()
        try scGame.save()
        
    }
    
    static func createMessage (user: User, game: Game, pointsOne: Int, pointsTwo: Int)throws {
        let te = try user.team()?.first()
        var mesteam: Team
        if try game.teamone()?.id == te?.id {
            mesteam = try game.teamtwo()!
        }else {
            mesteam = try game.teamone()!
        }
        let gameInMessage: Message? = try Message.query().filter("game",(game.id?.int)!).first()
        if gameInMessage == nil{
            var mes = try Message(game: (game.id?.int)!, resultOne: pointsOne, resultTwo: pointsTwo, scteam_id: (mesteam.id?.int)!)
            try mes.save()
        }
    }
    
    static func addPoints(winners: [User], losers: [User], dif: Int) throws{
        for user in winners{
            var us = user
            us.score += ((GameHelper.multPointsWinner) * (dif))
            try us.save()
        }
        for user in losers{
            var us = user
            us.score += ((GameHelper.multPointsLosers) * (dif))
            try us.save()
        }

    }
}
