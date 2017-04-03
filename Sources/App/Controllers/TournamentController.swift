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
        var user: User? = nil
        do {
            user = try request.auth.user() as? User
        } catch { return Response(redirect: "/sc/login")}
        
        let tour: [Tournament] = try Tournament.query().all()
        
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
        guard let tourname = request.formURLEncoded?["tournamentname"]?.string,
            let bday = request.formURLEncoded?["begdateDay"]?.string,
            let bmonth = request.formURLEncoded?["begdateMonth"]?.string,
            let byear = request.formURLEncoded?["begdateYear"]?.string,
            let eday = request.formURLEncoded?["enddateDay"]?.string,
            let emonth = request.formURLEncoded?["enddateMonth"]?.string,
            let eyear = request.formURLEncoded?["enddateYear"]?.string
            else {
                return "Mising name or dates"
            }
        let validatedbDay: Valid<DateValidator> = try bday.validated()
        let validatedbMonth: Valid<DateValidator> = try bmonth.validated()
        let validatedbYear: Valid<DateValidator> = try byear.validated()
        let validatedeDay: Valid<DateValidator> = try eday.validated()
        let validatedeMonth: Valid<DateValidator> = try emonth.validated()
        let validatedeYear: Valid<DateValidator> = try eyear.validated()
        
        let startDate = validatedbYear.value+"-"+validatedbMonth.value+"-"+validatedbDay.value+" 00:00:00"
        let endDate = validatedeYear.value+"-"+validatedeMonth.value+"-"+validatedeDay.value+" 23:59:00"
        let dateBeg = Game.dateFromString(startDate)
        let dateEnd = Game.dateFromString(endDate)
        
        var sctour: Tournament = Tournament(tourName: tourname, dateBeg: dateBeg, dateEnd: dateEnd)
        try sctour.save()
        return Response(redirect: "/sc/tour")
    }
    
    static func showGames(request: Request, sctour: Tournament)throws -> ResponseRepresentable{
        let games: [Game] = try sctour.games().all()
        var winner: Team? = nil
        
        var user: User? = nil
        do {
            user = try request.auth.user() as? User
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
    
    static func registerTeam (request: Request, sctour: Tournament, scteam: Team) throws -> ResponseRepresentable{
        if(try Pivot<Tournament,Team>.query().filter("team_id", scteam.id!).filter("tournament_id", sctour.id!).first() == nil){
            var pivot = Pivot<Tournament, Team> (sctour,scteam)
            try pivot.save()
        }
        return Response(redirect: "/sc/tour/"+(sctour.id?.string)!+"/games")
    }
    
    static func removeTeam(request: Request, sctour: Tournament, scteam: Team) throws -> ResponseRepresentable{
        let pivot = try Pivot<Tournament,Team>.query().filter("team_id", scteam.id!).filter("tournament_id", sctour.id!).first()
        if(pivot != nil){
            try pivot?.delete()
        }
        return Response(redirect: "/sc/tour/"+(sctour.id?.string)!+"/games")
    }
    
    static func startTournament (request: Request, sctour: Tournament)throws -> ResponseRepresentable{
        var tour: Tournament = sctour
        tour.open = false
        try TournamentHelper.createGames(tour: tour)
        try tour.save()
        return Response(redirect: "/sc/tour/"+(sctour.id?.string)!+"/games")
    }
    
}
