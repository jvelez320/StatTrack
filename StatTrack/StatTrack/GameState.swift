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
    var ball: Ball? = nil
    var rim: Rim? = nil
    var net: Net? = nil
    
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
    func updateBallCoordinates() {
        
    }
    func updatePlayersCoordinates() {
        
    }
    func updateRimCoordinates() {
        
    }
    func updateNetCoordinates() {
        
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
    var centerX: Double?
    var centerY: Double?
}

struct Rim {
    var centerX: Double?
    var centerY: Double?
}

struct Net {
    var centerX: Double?
    var centerY: Double?
}
