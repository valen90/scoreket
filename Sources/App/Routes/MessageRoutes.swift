//
//  MessageRoutes.swift
//  scoket
//
//  Created by Valen on 28/03/2017.
//
//

import Vapor
import HTTP
import Routing

class MessageRoutes: RouteCollection {
    typealias Wrapped = HTTP.Responder
    func build<B: RouteBuilder>(_ builder: B) where B.Value == Wrapped {
        let sc = builder.grouped("sc","messages")
        
        sc.get{ req in
            return try MessageController.indexView(request: req)
        }
    }
}
