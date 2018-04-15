//
//  Player.swift
//  COLHEX
//
//  Created by Alessandro Profenna on 2017-04-01.
//  Copyright © 2017 Alessandro Profenna. All rights reserved.
//

import Foundation
import SpriteKit

/**
 An individual player of the game. Includes a score, colour, and
 a pulse which is expanded when a user touches a coloured hex.
 */
class Player{
    
    var score: Int
    var colour: SKColor
    let pulse: Pulse
    var pulseMoved: Bool
    
    var isCPU: Bool
    var hexagons: [Int:Hexagon]
    
    /*
     Initializes the player's score, colour, and other properties
     */
    init(playerColour: SKColor) {
        score = 0
        colour = playerColour
        isCPU = false
        hexagons = [:]
        pulse = Pulse(playerColour: colour)
        pulseMoved = false
    }
    
    /**
     Adds the given Hexagon from the player's dictionary of
     hexagons that are coloured with the player's colour
     
     - parameters:
     -hex: The Hexagon that is to be added to the dictionary
     */
    func addHexagon(hex: Hexagon) {
        hexagons[hex.id] = hex
    }
    
    /**
     Removes the given Hexagon from the player's dictionary of
     hexagons that are coloured with the player's colour
 
     - parameters:
         -hex: The Hexagon that is to be removed from the dictionary
     */
    func removeHexagon(hex: Hexagon) {
        hexagons.removeValue(forKey: hex.id)
    }
    
    /**
     Randomly selects a hex with the player's colour, if there is one.
     
     - returns:
     An Integer ID of a hexagon from the array of hexagons.
     If there are no hexagon's to choose from that are coloured with the
     players colour, then -1 is returned.
     */
    func chooseHex() -> Int {
        let hexChoices = [Int](hexagons.keys)
        if(hexChoices.count > 0) {
            let randomID = Int(arc4random_uniform(UInt32(Int(hexChoices.count))))
            return hexChoices[randomID]
        }
        return -1
    }
}
