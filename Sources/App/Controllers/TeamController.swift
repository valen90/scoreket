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
        var user: SCUser? = nil
        do {
            user = try request.auth.user() as? SCUser
        } catch { return Response(redirect: "/sc/login")}
        
        guard let teamname = request.formURLEncoded?["teamname"]?.string
            else {
                return "Mising team name"
        }
        var team = SCTeam(teamName: teamname)
        try team.save()
        user?.scteam_id = (team.id?.int)!
        try user?.save()
        return Response(redirect: "/sc/team")
    }
    
    static func leaveTeam(request: Request , scuser: SCUser) throws -> ResponseRepresentable {
        var newUser: SCUser = scuser
        //let scteam = try SCTeam.find(scuser.scteam_id)
        newUser.scteam_id = nil
        try newUser.save()
        /*let users: [SCUser]? = try scteam?.users().all()
        
        if ((users?.count)! <= 0) {
            let g :[SCGame]? = try scteam?.games().all()
            for gi in g! {
                try gi.deletegame()
            }
            try scteam?.delete()
        }
        */
        return Response(redirect: "/sc/team")
    }
    
    static func createView(request: Request) throws -> ResponseRepresentable{
        return try drop.view.make("createTeam")
    }
    
    static func gamesIndex (request: Request, scteam: SCTeam) throws -> ResponseRepresentable{
        let games = try scteam.games()
        return try JSON(node: games.all().makeNode())
    }
    
    static func joinTeam(request: Request, scteam: SCTeam, scuser: SCUser) throws -> ResponseRepresentable {
        var user: SCUser = try SCUser.query().filter("id",scuser.id!).first()!
        user.scteam_id = (scteam.id?.int)!
        try user.save()
        return Response(redirect: "/sc/team")
    }
    
    static func userIndex(request: Request, scteam: SCTeam) throws -> ResponseRepresentable {
        let users = try scteam.users()
        return try JSON (node: [
                users.all().makeNode()
            ])
    }
    
    static func teamInfo(request: Request, scteam: SCTeam) throws -> ResponseRepresentable{
        var user: SCUser? = nil
        do {
            user = try request.auth.user() as? SCUser
        } catch { return Response(redirect: "/sc/login")}
        
        let games = try scteam.games().all()
        var vic = 0.0
        var gc = 0.0
        
        for game in games{
            if(game.ended){
                if (game.team1 == scteam.id!.int){
                    if(game.result1! > game.result2!){
                        vic+=1
                    }
                }else {
                    if(game.result2! > game.result1!){
                        vic+=1
                    }
                }
                gc+=1
            }
        }
        
        let ratio: Double = (vic/gc)*100.0
        let r: String = String(format: "%.2f", ratio)
        
        let parameters = try Node(node: [
            "team": scteam.makeJSON(),
            "users": scteam.users().sort("score", Sort.Direction.descending).all().makeJSON(),
            "games": games.makeJSON(),
            "user": user,
            "ratio": r,
            "wins": Int(vic),
            "loss": Int(gc-vic),
            "total": Int(gc),
            ])

        return try drop.view.make("teaminfo",parameters)
    }
    
    static func teamsView(request: Request) throws -> ResponseRepresentable {
        var user: SCUser? = nil
        do {
            user = try request.auth.user() as? SCUser
        } catch { return Response(redirect: "/sc/login")}
        let teamId = user?.scteam_id
        let parameters = try Node(node: [
            "teams": SCTeam.query().all().makeJSON(),
            "actualTeam": teamId,
            "user": user?.makeJSON()
            ])
        return try drop.view.make("teams", parameters)
    }
    
}
