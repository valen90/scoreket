//
//  TourtnamentController.swift
//  scoket
//
//  Created by Valen on 22/03/2017.
//
//

import Vapor
import HTTP
import Fluent
import Foundation

final class TourtnamentController{
    
    static func indexView(request: Request)throws -> ResponseRepresentable{
        var user: SCUser? = nil
        do {
            user = try request.auth.user() as? SCUser
        } catch { return Response(redirect: "/sc/login")}
        
        let tourt: [SCTourtnament] = try SCTourtnament.query().all()
        
        let parameters = try Node(node: [
            "tourt": tourt.makeJSON(),
            "user": user?.makeJSON()
            ])
        
        return try drop.view.make("tourtnaments", parameters)
    }
    
    static func createTourView(request: Request)throws -> ResponseRepresentable{
        return try drop.view.make("createTour")
    }
    
    static func createTour(request: Request)throws -> ResponseRepresentable{
        guard let tourname = request.formURLEncoded?["tournamentname"]?.string,
            let begdate = request.formURLEncoded?["begdate"]?.string,
            let enddate = request.formURLEncoded?["enddate"]?.string
            else {
                return "Mising name or dates"
        }

        
        var sctour: SCTourtnament = SCTourtnament(tourtName: tourname, dateBeg: begdate, dateEnd: enddate)
        try sctour.save()
        return Response(redirect: "/sc/tourt")
    }
    
    static func showGames(request: Request, sctourt: SCTourtnament)throws -> ResponseRepresentable{
        let games: [SCGame] = try sctourt.games().all()
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
            let teams: [SCTeam] = try sctourt.teams()
            for team in teams{
                var p = 0
                let tgames: [SCGame] = try team.games().filter("sctourtnament_id", sctourt.id!).all()
                for tgame in tgames{
                    if tgame.team1 == team.id?.int{
                        p += tgame.result1
                    }else {
                        p += tgame.result2
                    }
                }
                punct.append(p)
            }
            winner = teams[(punct.index(of: punct.max()!))!]
        }
        
        
        
        let parameters = try Node(node: [
            "game": games.makeJSON(),
            "tourt": sctourt.makeJSON(),
            "teams": sctourt.teams().makeJSON(),
            "ended": ended,
            "winner": winner?.makeJSON(),
            "user": user?.makeJSON()
            ])
        return try drop.view.make("games", parameters)
    }
    
    static func registerTeam (request: Request, sctourt: SCTourtnament, scteam: SCTeam) throws -> ResponseRepresentable{
        if(try Pivot<SCTourtnament,SCTeam>.query().filter("scteam_id", scteam.id!).filter("sctourtnament_id", sctourt.id!).first() == nil){
            var pivot = Pivot<SCTourtnament, SCTeam> (sctourt,scteam)
            try pivot.save()
        }
        return Response(redirect: "/sc/tourt/"+(sctourt.id?.string)!+"/games")
    }
    
    static func removeTeam(request: Request, sctourt: SCTourtnament, scteam: SCTeam) throws -> ResponseRepresentable{
        let pivot = try Pivot<SCTourtnament,SCTeam>.query().filter("scteam_id", scteam.id!).filter("sctourtnament_id", sctourt.id!).first()
        if(pivot != nil){
            try pivot?.delete()
        }
        return Response(redirect: "/sc/tourt/"+(sctourt.id?.string)!+"/games")
    }
    
    static func startTourtnament (request: Request, sctourt: SCTourtnament)throws -> ResponseRepresentable{
        var tourt: SCTourtnament = try SCTourtnament.query().filter("id", sctourt.id!).first()!
        tourt.open = false
        try tourt.save()
        var game: SCGame?
        var teams: [SCTeam] = try tourt.teams()
        var i = 0
        var j = 1
        
        /*let day = Int(Date().timeIntervalSince1970)
        let date = Date(timeIntervalSince1970: TimeInterval(day))
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "dd-MM-yyyy HH:mm:ss"
        print(dateFormatterGet.string(from: date))
        */
        
        while i < teams.count {
            while j < teams.count {
                game = try SCGame(team1: (teams[i].id?.int)!,team2: (teams[j].id?.int)!,date: "21",sctourtnament_id: (tourt.id?.int)!)
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
        //return try JSON(node: game?.makeJSON())
        return Response(redirect: "/sc/tourt/"+(sctourt.id?.string)!+"/games")
    }
    
}
