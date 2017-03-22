//
//  GameController.swift
//  scoket
//
//  Created by Valen on 21/03/2017.
//
//

import Vapor
import HTTP
import Fluent

final class GameController{
    func addRoutes(drop: Droplet){
        let sc = drop.grouped("sc","games")
        sc.get(handler: indexView)
    }
    
    func indexView(request: Request) throws -> ResponseRepresentable{
        var user: SCUser? = nil
        do {
            user = try request.auth.user() as? SCUser
        } catch { return Response(redirect: "/sc/login")}
        
        let team:SCTeam? = try user?.team().first()
        let games: [SCGame]? = try team?.games()
        
        let parameters = try Node(node: [
            "authenticated": user != nil,
            "game": games?.makeJSON(),
            "user": user?.makeJSON()
            ])
        //return try JSON(node: games?.makeJSON())
        return try drop.view.make("games", parameters)
    }
}
