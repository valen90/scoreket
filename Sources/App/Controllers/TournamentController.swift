//
//  TournamentController.swift
//  scoket
//
//  Created by Valen on 22/03/2017.
//
//

import Vapor
import HTTP
import Fluent
import Foundation

final class TournamentController{
    
    static func indexView(request: Request)throws -> ResponseRepresentable{
        var user: SCUser? = nil
        do {
            user = try request.auth.user() as? SCUser
        } catch { return Response(redirect: "/sc/login")}
        
        let tour: [SCTournament] = try SCTournament.query().all()
        
        let parameters = try Node(node: [
            "tour": tour.makeJSON(),
            "user": user?.makeJSON()
            ])
        
        return try drop.view.make("tournaments", parameters)
    }
    
    static func createTourView(request: Request)throws -> ResponseRepresentable{
        return try drop.view.make("createTour")
    }
    
    static func createTour(request: Request)throws -> ResponseRepresentable{
        guard let tourname = request.formURLEncoded?["tournamentname"]?.string//,
            //let begdate = request.formURLEncoded?["begdate"]?.string,
            //let enddate = request.formURLEncoded?["enddate"]?.string
            else {
                return "Mising name or dates"
        }

        var sctour: SCTournament = SCTournament(tourName: tourname, dateBeg: nil, dateEnd: nil)
        try sctour.save()
        return Response(redirect: "/sc/tour")
    }
    
    static func showGames(request: Request, sctour: SCTournament)throws -> ResponseRepresentable{
        let games: [SCGame] = try sctour.games().all()
        var user: SCUser? = nil
        do {
            user = try request.auth.user() as? SCUser
        } catch { return Response(redirect: "/sc/login")}
        
        var ed = 0
        var ended = false
        var winner: SCTeam? = nil
        
        for game in games{
            if game.ended{
                ed += 1
            }
        }
        
        var punct: [Int] = []
        
        if games.count == ed && ed>0{
            ended = true
            let teams: [SCTeam] = try sctour.teams()
            for team in teams{
                var p = 0
                let tgames: [SCGame] = try team.games().filter("sctournament_id", sctour.id!).all()
                for tgame in tgames{
                    if tgame.team1 == team.id?.int{
                        if tgame.result1 != nil{
                            p += tgame.result1!
                        }
                    }else {
                        if tgame.result2 != nil{
                            p += tgame.result2!
                        }
                    }
                }
                punct.append(p)
            }
            winner = teams[(punct.index(of: punct.max()!))!]
        }
        
        
        
        let parameters = try Node(node: [
            "game": games.makeJSON(),
            "tour": sctour.makeJSON(),
            "teams": sctour.teams().makeJSON(),
            "ended": ended,
            "winner": winner?.makeJSON(),
            "user": user?.makeJSON()
            ])
        return try drop.view.make("games", parameters)
    }
    
    static func registerTeam (request: Request, sctour: SCTournament, scteam: SCTeam) throws -> ResponseRepresentable{
        if(try Pivot<SCTournament,SCTeam>.query().filter("scteam_id", scteam.id!).filter("sctournament_id", sctour.id!).first() == nil){
            var pivot = Pivot<SCTournament, SCTeam> (sctour,scteam)
            try pivot.save()
        }
        return Response(redirect: "/sc/tour/"+(sctour.id?.string)!+"/games")
    }
    
    static func removeTeam(request: Request, sctour: SCTournament, scteam: SCTeam) throws -> ResponseRepresentable{
        let pivot = try Pivot<SCTournament,SCTeam>.query().filter("scteam_id", scteam.id!).filter("sctournament_id", sctour.id!).first()
        if(pivot != nil){
            try pivot?.delete()
        }
        return Response(redirect: "/sc/tour/"+(sctour.id?.string)!+"/games")
    }
    
    static func startTournament (request: Request, sctour: SCTournament)throws -> ResponseRepresentable{
        var tour: SCTournament = try SCTournament.query().filter("id", sctour.id!).first()!
        tour.open = false
        
        var game: SCGame?
        var teams: [SCTeam] = try tour.teams()
        var i = 0
        var j = 1
        
        /*let day = Int(Date().timeIntervalSince1970)
        let date = Date(timeIntervalSince1970: TimeInterval(day))
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "dd-MM-yyyy HH:mm:ss"
        print(dateFormatterGet.string(from: date))
        */
        var now = Date()
        var comp = DateComponents()
        comp.weekday = 6
        comp.hour = 17
        comp.minute = 30
        var comingFriday = Calendar.current.nextDate(after: now,
                                                     matching: comp,
                                                     matchingPolicy: .nextTime)
        tour.dateBeg = comingFriday!
        while i < teams.count {
            while j < teams.count {
                game = try SCGame(team1: teams[i].id!.int! ,team2: teams[j].id!.int!,date: comingFriday!,sctournament_id: (tour.id?.int)!,result1: nil,result2: nil)
                now = comingFriday!
                tour.dateEnd = comingFriday!
                comingFriday = Calendar.current.nextDate(after: now,
                                                         matching: comp,
                                                         matchingPolicy: .nextTime)
                try game?.save()
                var pivot = Pivot<SCTeam, SCGame> (teams[i],game!)
                try pivot.save()
                pivot = Pivot<SCTeam, SCGame> (teams[j],game!)
                try pivot.save()
                j += 1
            }
            i += 1
            j = i+1
        }
        
        try tour.save()
        //return try JSON(node: game?.makeJSON())
        return Response(redirect: "/sc/tour/"+(sctour.id?.string)!+"/games")
    }
    
}
