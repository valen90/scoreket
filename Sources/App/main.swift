import Vapor
import VaporMySQL
import Auth
import Fluent
import Foundation

let drop = Droplet()
try drop.addProvider(VaporMySQL.Provider)

drop.preparations += Team.self
drop.preparations += User.self
drop.preparations += Tournament.self
drop.preparations += Game.self
drop.preparations += Message.self
drop.preparations += Pivot<Team,Game>.self
drop.preparations += Pivot<Tournament, Team>.self

drop.addConfigurable(middleware: AuthMiddleware(user: User.self), name: "auth")

let team = TeamRoutes()
drop.collection(team)

let tour = TournamentRoutes()
drop.collection(tour)

let user = UserRoutes()
drop.collection(user)

let game = GameRoutes()
drop.collection(game)

let message = MessageRoutes()
drop.collection(message)

drop.run()
