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
        return "hola"
    }
}
