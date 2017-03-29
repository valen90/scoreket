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
        guard let tourname = request.formURLEncoded?["tournamentname"]?.string
            else {
                return "Mising name"
        }

        var sctour: SCTournament = SCTournament(tourName: tourname, dateBeg: nil, dateEnd: nil)
        try sctour.save()
        return Response(redirect: "/sc/tour")
    }
    
    static func showGames(request: Request, sctour: SCTournament)throws -> ResponseRepresentable{
        let games: [SCGame] = try sctour.games().all()
        var winner: SCTeam? = nil
        
        var user: SCUser? = nil
        do {
            user = try request.auth.user() as? SCUser
        } catch { return Response(redirect: "/sc/login")}
        
        if sctour.ended == true{
            winner = try sctour.getWinner()
        }
        
        let parameters = try Node(node: [
            "game": games.makeJSON(),
            "tour": sctour.makeJSON(),
            "teams": sctour.teams().makeJSON(),
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
        var tour: SCTournament = sctour
        tour.open = false
        try TournamentHelper.createGames(tour: tour)
        try tour.save()
        return Response(redirect: "/sc/tour/"+(sctour.id?.string)!+"/games")
    }
    
}
