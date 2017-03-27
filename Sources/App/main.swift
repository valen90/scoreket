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
drop.preparations += SCTournament.self
drop.preparations += Pivot<SCTeam,SCGame>.self
drop.preparations += Pivot<SCTournament, SCTeam>.self

drop.addConfigurable(middleware: AuthMiddleware(user: SCUser.self), name: "auth")

let team = TeamRoutes()
drop.collection(team)

let tour = TournamentRoutes()
drop.collection(tour)

let user = UserRoutes()
drop.collection(user)

let game = GameRoutes()
drop.collection(game)

drop.run()
