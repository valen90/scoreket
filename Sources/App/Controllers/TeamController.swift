//
//  TeamController.swift
//  scoket
//
//  Created by Valen on 21/03/2017.
//
//

import Vapor
import HTTP
import Turnstile
import Fluent

final class TeamController{

    static func create(request: Request) throws -> ResponseRepresentable {
        var user: User? = nil
        do {
            user = try request.auth.user() as? User
        } catch { return Response(redirect: "/sc/login")}
        
        guard let teamname = request.formURLEncoded?["teamname"]?.string
            else {
                return "Mising team name"
        }
        var team = Team(teamName: teamname)
        try team.save()
        user?.scteam_id = (team.id?.int)!
        try user?.save()
        return Response(redirect: "/sc/team")
    }
    
    static func leaveTeam(request: Request , scuser: User) throws -> ResponseRepresentable {
        var newUser: User = scuser
        newUser.scteam_id = nil
        try newUser.save()
        return Response(redirect: "/sc/team")
    }
    
    static func createView(request: Request) throws -> ResponseRepresentable{
        return try drop.view.make("createTeam")
    }
    
    static func gamesIndex (request: Request, scteam: Team) throws -> ResponseRepresentable{
        let games = try scteam.games()
        return try JSON(node: games.all().makeNode())
    }
    
    static func joinTeam(request: Request, scteam: Team, scuser: User) throws -> ResponseRepresentable {
        var user: User = try User.query().filter("id",scuser.id!).first()!
        user.scteam_id = (scteam.id?.int)!
        try user.save()
        return Response(redirect: "/sc/team")
    }
    
    static func userIndex(request: Request, scteam: Team) throws -> ResponseRepresentable {
        let users = try scteam.users()
        return try JSON (node: [
                users.all().makeNode()
            ])
    }
    
    static func teamInfo(request: Request, scteam: Team) throws -> ResponseRepresentable{
        var user: User? = nil
        do {
            user = try request.auth.user() as? User
        } catch { return Response(redirect: "/sc/login")}
        
        let games = try scteam.games().all()
        
        let ratio: Double = (Double(scteam.wins)/Double(scteam.totalGames))*100
        let r: String = String(format: "%.2f", ratio)
        
        let parameters = try Node(node: [
            "team": scteam.makeJSON(),
            "users": scteam.users().sort("score", Sort.Direction.descending).all().makeJSON(),
            "games": games.makeJSON(),
            "user": user,
            "ratio": r,
            "wins": scteam.wins,
            "loss": scteam.losses,
            "total": scteam.totalGames,
            ])

        return try drop.view.make("teaminfo",parameters)
    }
    
    static func teamsView(request: Request) throws -> ResponseRepresentable {
        var user: User? = nil
        do {
            user = try request.auth.user() as? User
        } catch { return Response(redirect: "/sc/login")}
        let teamId = user?.scteam_id
        let parameters = try Node(node: [
            "teams": Team.query().all().makeJSON(),
            "actualTeam": teamId,
            "user": user?.makeJSON()
            ])
        return try drop.view.make("teams", parameters)
    }
    
}
