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
    static let weekDay = 6 // Friday
    static let hour = 17
    static let minute = 30 // 17:30
    static let topHour = 19 // 19:30
    
    /*
     Create all the games for the dates availables
     */
    static func createGames (tour: Tournament) throws{
        
        let teams: [Team] = try tour.teams()
        var copy: [Team] = teams
        var game: Game?
        var gameCalendar = TournamentHelper.getGamingCalendar(
            begDay: tour.dateBeg!,
            endDay: tour.dateEnd!)
        var i = 0
        var j = 1
        var teamOne: Team
        var teamTwo: Team
        
        
        while gameCalendar.count-1 >= 0 {
            teamOne = copy[i]
            teamTwo = copy[j]
            game = try Game(
                team1: (teamOne.id?.int)!,
                team2: (teamTwo.id?.int)!,
                date: gameCalendar.remove(at: 0),
                sctournament_id: (tour.id?.int)!,
                result1: nil,
                result2: nil)
            
            try game?.save()
            var pivot = Pivot<Team, Game> (teamOne,game!)
            try pivot.save()
            pivot = Pivot<Team, Game> (teamTwo,game!)
            try pivot.save()
            i = (i+1) % (copy.count)
            j = (i+1) % (copy.count)
        }
    }
    /*
     Gets the winner of the Tournament adding the winners of all the games
     */
    static func calculateWinner(tour: Tournament)throws -> Int{
        let tourId = tour.id!.int
        
        guard let database = drop.database else {
            throw Abort.serverError
        }
        
        let node = try database.driver.raw("SELECT winner FROM games WHERE tournament_id = \(tourId ?? -1) GROUP BY winner ORDER BY COUNT(*) DESC LIMIT 1")
        
        guard case .array(let array) = node,
            let winnerObject = array.first,
            let winnerId = winnerObject["winner"]?.int
        else {
            throw Abort.serverError
        }
        
        return winnerId
    }
    
    /*
     Gets the available dates for a game between the given dates
     */
    
    static func getGamingCalendar(begDay: Date, endDay: Date) -> [Date]{
        
        var gameCalendar: [Date] = []
        var iteratorDay = begDay
        let endDay = endDay
        var comp = DateComponents()
        comp.weekday = TournamentHelper.weekDay
        comp.hour = TournamentHelper.hour
        comp.minute = TournamentHelper.minute
        
        while(iteratorDay <= endDay){
            iteratorDay = Calendar.current.nextDate(
                after: iteratorDay,
                matching: comp,
                matchingPolicy: .nextTime)!
            
            gameCalendar.append(iteratorDay)
            
            if comp.hour! < topHour {
                comp.hour! += 1
            } else {
                comp.hour = TournamentHelper.hour
            }
            
        }
        return gameCalendar
    }
    
}
