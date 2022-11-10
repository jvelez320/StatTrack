//
//  GameState.swift
//  StatTrack
//
//  Created by Ryan Hamby on 11/3/22.
//

import Foundation
import SQLite
// comment 2
// Note: this is not Apple's SQLite3. It is a layer over this SQLite3 for Swift syntax.
// Reference from: https://github.com/stephencelis/SQLite.swift

// Store data of the game at CURRENT time. When TFLite model returns info about a frame,
// we will update the GameState first, then update + query the SQLite DB with some of this info.
// All calls about CURRENT score, object positions, possession, etc. should be sourced from here.
// GameState includes methods that query the DB to look for made basket events, etc.
let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("dbStatTrack.sqlite3")

func initiailizeDB() -> () {
    do {
        print(fileURL.path)
        
        let db = try Connection(fileURL.path)

        let frames = Table("frames")
        let fid = Expression<Int64>("fid")
        let ballX = Expression<Double?>("ballX")
        let ballY = Expression<Double?>("ballY")
        let rimX = Expression<Double?>("rimX")
        let rimY = Expression<Double?>("rimY")
        let netX = Expression<Double?>("netX")
        let netY = Expression<Double?>("netY")
        let teamAPos = Expression<Double?>("teamAPos")
        let teamBPos = Expression<Double?>("teamBPos")
        let time = Expression<Date>("time")
        
        try db.run(frames.drop(ifExists: true))

        try db.run(frames.create { t in
            t.column(fid, primaryKey: true)
            t.column(ballX)
            t.column(ballY)
            t.column(rimX)
            t.column(rimY)
            t.column(netX)
            t.column(netY)
            t.column(teamAPos)
            t.column(teamBPos)
            t.column(time)
        })
        
        try print(db.schema.columnDefinitions(table: "frames"))
        
        // CREATE TABLE "users" (
        //     "id" INTEGER PRIMARY KEY NOT NULL,
        //     "name" TEXT,
        //     "email" TEXT NOT NULL UNIQUE
        // )

        //let insert = users.insert(name <- "Alice", email <- "alice@mac.com")
        //let rowid = try db.run(insert)
        // INSERT INTO "users" ("name", "email") VALUES ('Alice', 'alice@mac.com')

        //for user in try db.prepare(users) {
            //print("id: \(user[id]), name: \(user[name]), email: \(user[email])")
            // id: 1, name: Optional("Alice"), email: alice@mac.com
        //}
        // SELECT * FROM "users"

        //let alice = users.filter(id == rowid)

        //try db.run(alice.update(email <- email.replace("mac.com", with: "me.com")))
        // UPDATE "users" SET "email" = replace("email", 'mac.com', 'me.com')
        // WHERE ("id" = 1)

        //try db.run(alice.delete())
        // DELETE FROM "users" WHERE ("id" = 1)

        //try db.scalar(users.count) // 0
        
        // SELECT count(*) FROM "users"
    } catch {
        print("Error creating database")
        print (error)
    }
}

struct GameState {
    var currentTime: Double? = nil
    var teamAHasOfficialPossesion: Bool = false
    var recentShotAttempt: Bool = false // 3 second buffer if becomes true
    var recentMadeShot: Bool = false // 3 second buffer if becomes true
    
    var teamA: Team? = nil
    var teamB: Team? = nil
    var ball: Ball
    var rim: Rim
    var net: Net
    
    let db = try Connection(fileURL.path)
    
    mutating func checkShotAttempt() -> Bool {
        return ball.centerY > rim.centerY && abs(ball.centerX - rim.centerX) < 100
    }
    mutating func checkMadeBasket() -> Bool {
        return false
    }
    mutating func checkPossesionChange() -> Bool {
        return false
    }
    func determineWhichTeamShot() -> String {
        return "none"
    }
    mutating func updateBallCoordinates(xCoord: Double, yCoord: Double) {
        ball.centerX = xCoord
        ball.centerY = yCoord
    }
    func updatePlayersCoordinates() {
    
    }
    mutating func updateRimCoordinates(xCoord: Double, yCoord: Double) {
        print(rim.centerX ?? -1)
        rim.centerX = xCoord
        rim.centerY = yCoord
        print(rim.centerX ?? -1)
    }
    mutating func updateNetCoordinates(xCoord: Double, yCoord: Double) {
        net.centerX = xCoord
        net.centerY = yCoord
    }
    
}

extension GameState {
    init() {
        ball = Ball()
        rim = Rim()
        net = Net()
        initiailizeDB()
    }
}

struct Team {
    var name: String
    var shirtColor: String
    var perceivedPossession: Double
    var numMakes: Int
    var numMisses: Int
}

struct Ball {
    var centerX: Double? = nil
    var centerY: Double? = nil
}

struct Rim {
    var centerX: Double? = nil
    var centerY: Double? = nil
}

struct Net {
    var centerX: Double? = nil
    var centerY: Double? = nil
}
