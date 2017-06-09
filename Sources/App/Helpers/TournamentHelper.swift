import Vapor
import Foundation
import Fluent
import Sugar

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
        var gameCalendar = try TournamentHelper.getGamingCalendar(
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
    
    static func getGamingCalendar(begDay: Date, endDay: Date) throws -> [Date]{
        
        var gameCalendar: [Date] = []
        var iteratorDay = begDay
        let endDay = endDay
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        iteratorDay = iteratorDay.addingTimeInterval(TimeInterval(self.hour * 3600 + self.minute * 60))

        while(endDay.isAfter(iteratorDay)){
            var components = calendar.dateComponents([.hour, .weekday], from: iteratorDay)
            guard let hour = components.hour else {
                throw Abort.serverError
            }

            if hour < self.topHour {
                if components.weekday != self.weekDay {
                    iteratorDay = try next(.friday, from: iteratorDay)
                }
                iteratorDay = iteratorDay.addingTimeInterval(TimeInterval(3600))
            }
            else {
                iteratorDay = iteratorDay.addingTimeInterval(TimeInterval(16200 + (self.hour * 3600 + self.minute * 60))) // 16200 is the diference between the actual hour and the end of the day in seconds
                iteratorDay = try next(.friday, from: iteratorDay)
            }

            gameCalendar.append(iteratorDay)
            
        }
        return gameCalendar
    }

    enum Weekday: Int {
        case sunday = 1
        case monday
        case tuesday
        case wednesday
        case thursday
        case friday
        case saturday
    }

    static func next(_ weekday: Weekday, from date: Date) throws -> Date {
        var date = date
        let components = Calendar(identifier: .gregorian).dateComponents([.weekday], from: date)
        guard let day = components.weekday else {
            throw Abort.serverError
        }

        var delta = weekday.rawValue - day
        if delta <= 0 {
            delta += 7
        }
        date = date.addDays(delta)

        return date
    }
    
}
