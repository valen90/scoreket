//
//  TeamHelper.swift
//  scoket
//
//  Created by Valen on 29/03/2017.
//
//
import Vapor
import Foundation
import Fluent

final class TournamentHelper{
    
    static func createGames (tour: SCTournament) throws{
        var game: SCGame?
        var teams: [SCTeam] = try tour.teams()
        var i = 0
        var j = 1
        
        var now = Date()
        var comp = DateComponents()
        comp.weekday = 6 //Friday
        comp.hour = 17
        comp.minute = 30
        var comingFriday = Calendar.current.nextDate(after: now,
                                                     matching: comp,
                                                     matchingPolicy: .nextTime)  // ComingFriday will be the Date corresponding to the next Friday at 17:30
        tour.dateBeg = comingFriday!
        while i < teams.count {
            while j < teams.count {
                game = try SCGame(
                    team1: teams[i].id!.int!,
                    team2: teams[j].id!.int!,
                    date: comingFriday!,
                    sctournament_id: (tour.id?.int)!,
                    result1: nil,
                    result2: nil)                                               //we create the game with the data of the teams
                
                now = comingFriday!
                tour.dateEnd = comingFriday!
                comingFriday = Calendar.current.nextDate(after: now,
                                                         matching: comp,
                                                         matchingPolicy: .nextTime)  // Update the date for the next Friday
                try game?.save()
                var pivot = Pivot<SCTeam, SCGame> (teams[i],game!)
                try pivot.save()
                pivot = Pivot<SCTeam, SCGame> (teams[j],game!)
                try pivot.save()                                            //Update the pivot tables
                j += 1
            }
            i += 1
            j = i+1
        }
    }
    
    static func calculateWinner(tour: SCTournament)throws -> SCTeam?{
        var winner: SCTeam? = nil
        var punct: [Int] = []
        let teams: [SCTeam] = try tour.teams()
        for team in teams{
            var p = 0
            let tgames: [SCGame] = try team.games().filter("sctournament_id", tour.id!).all()
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
        return winner
    }
    
}
