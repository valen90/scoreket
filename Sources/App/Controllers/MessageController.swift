//
//  MessageController.swift
//  scoket
//
//  Created by Valen on 28/03/2017.
//
//

import Vapor
import HTTP
import Fluent

final class MessageController{
    static func indexView(request: Request) throws -> ResponseRepresentable{
        var user: SCUser? = nil
        do {
            user = try request.auth.user() as? SCUser
        } catch { return Response(redirect: "/sc/login")}
        
        var mes: [Message]? = []
        let team: SCTeam? = try (user?.team().first())
        if team != nil{
            mes = try team?.messages().all()
        }
        let parameters = try Node(node: [
            "user": user?.makeJSON(),
            "message": mes?.makeJSON()
            ])
        
        return try drop.view.make("messages", parameters)
    }
}
