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
    var teamAHasOfficialPossesion: Bool? = nil
    var recentShotAttempt: Date = Date().advanced(by: -4) // 3 second buffer if becomes true
	var recentMadeShot: Date = Date().advanced(by: -4) // 3 second buffer if becomes true
    
    var teamA: Team
    var teamB: Team
    var ball: Ball
    var rim: Rim
    var net: Net
    
//    let db = try Connection(fileURL.path)
    
    mutating func checkShotAttempt() -> Bool {
		// TODO: fine tune this parameter
		let threshold: CGFloat = 70
        if let ballCenterX = ball.centerX, let ballCenterY = ball.centerY, let rimCenterX = rim.centerX, let rimCenterY = rim.centerY {
            if (ballCenterY < rimCenterY && abs(ballCenterX - rimCenterX) < threshold) {
                if (Date() > recentShotAttempt.advanced(by: 3)) {
                    recentShotAttempt = Date()
					// Checking for new shot attempts only: old code returned true no matter the time difference
					return true
                }
            }
        }
        return false
    }
    mutating func checkMadeBasket() -> Bool? {
		// TODO: fine tune these parameters
		let heightThreshold: CGFloat = 10
		let distanceThreshold: CGFloat = 30
		if Date() < recentMadeShot.advanced(by: 3) {
			return nil
		}

		print("recentMadeShot: \(recentMadeShot)")
		if let ballCenterX = ball .centerX, let ballCenterY = ball.centerY, let rimCenterX = rim.centerX, let rimCenterY = rim.centerY, let ballHeight = ball.height, let rimHeight = rim.height {
			print("ball coords: (\(ballCenterX), \(ballCenterY))")
			print("rim coords: (\(rimCenterX), \(rimCenterY))")
			print("recentShotAttempt: \(recentShotAttempt)")
			print("current time: \(Date())")
			if ballCenterY > rimCenterY && Date() < recentShotAttempt.advanced(by: 3) {
				print("distance diff: \(abs(ballCenterX - rimCenterX))")
				print("height diff: \(abs(ballHeight - rimHeight))")
				if abs(ballHeight - rimHeight) < heightThreshold && abs(ballCenterX - rimCenterX) < distanceThreshold {
					recentMadeShot = Date()
					// Checking for new shot attempts only: old code returned true no matter the time difference
					return true
				} else {
					recentMadeShot = Date()
					return false // miss
				}
			}
		}
		
		return nil
    }
	mutating func updateOfficialPossesion(teamACoords: [(Double, Double)], teamBCoords: [(Double, Double)]) -> Void {
		if let ballCenterX = ball.centerX, let ballCenterY = ball.centerY {
			var teamAHasCurrentPossession = false
			var minDistance = Double.greatestFiniteMagnitude
			for coordPair in teamACoords {
				let currDistance = sqrt(pow(coordPair.0 - ballCenterX, 2) + pow(coordPair.1 - ballCenterY, 2))
				if currDistance < minDistance {
					teamAHasCurrentPossession = true
					minDistance = currDistance
				}
			}
			
			for coordPair in teamBCoords {
				let currDistance = sqrt(pow(coordPair.0 - ballCenterX, 2) + pow(coordPair.1 - ballCenterY, 2))
				if currDistance < minDistance {
					teamAHasCurrentPossession = false
					break
				}
			}
			
			if teamAHasCurrentPossession {
				teamA.perceivedPossession = Date()
				//if Date() > teamB.perceivedPossession.advanced(by: 3) {
					teamAHasOfficialPossesion = true
				//}
			} else {
				teamB.perceivedPossession = Date()
				//if Date() > teamA.perceivedPossession.advanced(by: 3) {
					teamAHasOfficialPossesion = false
				//}
			}
		}
    }
    func determineWhichTeamShot() -> String {
        return "none"
    }
    mutating func updateBallCoordinates(xCoord: Double, yCoord: Double) {
        ball.centerX = xCoord
        ball.centerY = yCoord
    }
	mutating func updateBallSize(height: Double, width: Double) {
		ball.height = height
		ball.width = width
	}
    func updatePlayersCoordinates() {
    
    }
    mutating func updateRimCoordinates(xCoord: Double, yCoord: Double) {
        rim.centerX = xCoord
        rim.centerY = yCoord
    }
	mutating func updateRimSize(height: Double, width: Double) {
		rim.height = height
		rim.width = width
	}
    mutating func updateNetCoordinates(xCoord: Double, yCoord: Double) {
        net.centerX = xCoord
        net.centerY = yCoord
    }
	mutating func updateNetSize(height: Double, width: Double) {
		net.height = height
		net.width = width
	}
}

extension GameState {
    init() {
        ball = Ball()
        rim = Rim()
        net = Net()
		teamA = Team()
		teamB = Team()
        initiailizeDB()
    }
}

struct Team {
    var name: String = ""
    var shirtColor: UIColor = UIColor()
    var perceivedPossession: Date = Date()
    var numMakes: Int = 0
    var numMisses: Int = 0
}

struct Ball {
    var centerX: Double? = nil
    var centerY: Double? = nil
	var height: Double? = nil
	var width: Double? = nil
}

struct Rim {
    var centerX: Double? = nil
    var centerY: Double? = nil
	var height: Double? = nil
	var width: Double? = nil
}

struct Net {
    var centerX: Double? = nil
    var centerY: Double? = nil
	var height: Double? = nil
	var width: Double? = nil
}
