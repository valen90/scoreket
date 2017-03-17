import Vapor
import VaporMySQL
import Auth
import Fluent
import Foundation

let drop = Droplet()
try drop.addProvider(VaporMySQL.Provider)
drop.preparations += SCUser.self
drop.preparations += SCGame.self

drop.addConfigurable(middleware: AuthMiddleware(user: SCUser.self), name: "auth")

let sc = SCController()
sc.addRoutes(drop: drop)


drop.get("date"){ req in
    let date = Date()
    let calendar = Calendar.current
    let hour = calendar.component(.hour, from: date)
    let minutes = calendar.component(.minute, from: date)
    return try JSON(node: [
            "hour": hour,
            "minutes": minutes
        ])
}

drop.get("games"){req in
    return try JSON(node: SCGame.all().makeNode())
}

drop.run()
