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
    func addRoutes(drop: Droplet){
        let sc = drop.grouped("sc","team")
        sc.get(handler: teamsView)
        sc.post(handler: create)
        sc.get("create", handler: createView)
        sc.get(SCUser.self, "leave",handler: leaveTeam)
        sc.get(SCTeam.self, "games", handler: gamesIndex)
        sc.post(SCTeam.self,"join",SCUser.self,handler: joinTeam)
        sc.get(SCTeam.self, "users", handler: userIndex)
    }

    func create(request: Request) throws -> ResponseRepresentable {
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
    
    func leaveTeam(request: Request , scuser: SCUser) throws -> ResponseRepresentable {
        var newUser: SCUser = try SCUser.query().filter("id", scuser.id!).first()!
        newUser.scteam_id = 0
        try newUser.save()
        return Response(redirect: "/sc/team")
    }
    
    func createView(request: Request) throws -> ResponseRepresentable{
        return try drop.view.make("createTeam")
    }
    
    func gamesIndex (request: Request, scteam: SCTeam) throws -> ResponseRepresentable{
        let games = try scteam.games()
        return try JSON(node: games.makeNode())
    }
    
    func joinTeam(request: Request, scteam: SCTeam, scuser: SCUser) throws -> ResponseRepresentable {
        var user: SCUser = try SCUser.query().filter("id",scuser.id!).first()!
        user.scteam_id = (scteam.id?.int)!
        try user.save()
        return Response(redirect: "/sc/team")
    }
    
    func userIndex(request: Request, scteam: SCTeam) throws -> ResponseRepresentable {
        let users = try scteam.users()
        return try JSON (node: [
                users.all().makeNode()
            ])
    }
    
    func teamsView(request: Request) throws -> ResponseRepresentable {
        var user: SCUser? = nil
        do {
            user = try request.auth.user() as? SCUser
        } catch { return Response(redirect: "/sc/login")}
        let teamId = user?.scteam_id
        let parameters = try Node(node: [
            "teams": SCTeam.query().all().makeJSON(),
            "actualTeam": teamId,
            "authenticated": user != nil,
            "user": user?.makeJSON()
            ])
        return try drop.view.make("teams", parameters)
    }
    
}
