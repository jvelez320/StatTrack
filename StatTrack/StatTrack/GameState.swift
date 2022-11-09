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
    
    mutating func checkShotAttempt() -> Bool {
        return false
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
        print(rim.centerX)
        rim.centerX = xCoord
        rim.centerY = yCoord
        print(rim.centerX)
    }
    mutating func updateNetCoordinates(xCoord: Double, yCoord: Double) {
        net.centerX = xCoord
        net.centerY = yCoord
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
