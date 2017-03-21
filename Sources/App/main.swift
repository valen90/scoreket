import Vapor
import VaporMySQL
import Auth
import Fluent
import Foundation

let drop = Droplet()
try drop.addProvider(VaporMySQL.Provider)
drop.preparations += SCUser.self
drop.preparations += SCGame.self
drop.preparations += SCTeam.self
drop.preparations += Pivot<SCTeam,SCGame>.self


drop.addConfigurable(middleware: AuthMiddleware(user: SCUser.self), name: "auth")

let sc = UserController()
sc.addRoutes(drop: drop)

let game = GameController()
game.addRoutes(drop: drop)

let team = TeamController()
team.addRoutes(drop: drop)

drop.run()
