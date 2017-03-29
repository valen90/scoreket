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
    
    static func updateScores(message: Message)throws {
        var scGame: Game = try message.returnGame()!
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
        
        try teamW?.save()
        try teamL?.save()
        
        for user in grtusers!{
            var us = user
            us.score += 10*(gr-ls)
            try us.save()
        }
        for user in lssusers!{
            var us = user
            us.score += -5*(gr-ls)
            try us.save()
        }
        scGame.ended = true
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
}
