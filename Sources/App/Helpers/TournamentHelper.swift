//
//  TournamentHelper.swift
//  scoket
//
//  Created by Valen on 29/03/2017.
//
//

import Vapor
import Foundation
import Fluent

final class TournamentHelper{
    
    static func createGames (tour: Tournament) throws{
        var game: Game?
        var teams: [Team] = try tour.teams()
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
                game = try Game(
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
                var pivot = Pivot<Team, Game> (teams[i],game!)
                try pivot.save()
                pivot = Pivot<Team, Game> (teams[j],game!)
                try pivot.save()                                            //Update the pivot tables
                j += 1
            }
            i += 1
            j = i+1
        }
    }
    
    static func calculateWinner(tour: Tournament)throws -> Team?{
        var winner: Team? = nil
        var punct: [Int] = []
        let teams: [Team] = try tour.teams()
        for team in teams{
            var p = 0
            let tgames: [Game] = try team.games().filter("tournament_id", tour.id!).all()
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
