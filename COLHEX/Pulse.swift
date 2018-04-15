//
//  Pulse.swift
//  COLHEX
//
//  Created by Alessandro Profenna on 2017-04-01.
//  Copyright © 2017 Alessandro Profenna. All rights reserved.
//

import Foundation
import SpriteKit

/**
 An invisible circular pulse. It expands from the hexagons that are touched by players during the game.
 Each player will have only one pulse. It resizes and moves each time a hexagon is touched.
 */
class Pulse: SKSpriteNode{
    
    let defaultSize: CGSize
    
    /*
     Initializes the pulse's texture, colour, and other properties
     */
    init(playerColour: SKColor) {
        let texture = SKTexture(imageNamed: BLANK_HEX_SMALL)
        defaultSize = texture.size()
        super.init(texture: texture, color: playerColour, size: texture.size())
        self.anchorPoint = ANCHOR_POINT_CENTER
        self.alpha = 0.0
        self.color = playerColour
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     Sets the width and height of the pulse to the given width and height.
     This is used to shrink the pulse back to it's default size.
     
     - parameters:
     - pulseWidth: The desired width of the pulse.
     - pulseHeight: The desired height of the pulse.
     */
    func resize(pulseWidth: CGFloat, pulseHeight: CGFloat) {
        let spriteWidth = defaultSize.width
        let spriteHeight = defaultSize.height
        self.xScale = ((pulseWidth/HEX_SCALE_FACTOR) / spriteWidth)
        self.yScale = ((pulseHeight/HEX_SCALE_FACTOR) / spriteHeight)
    }
    
    /**
     Gives the Pulse a circular physics body in order to detect the hexagon objects that it touches
     as it expands from a player touch location.
     
     - parameters:
     - radius: The desired radius of the pulse's physics body.
     */
    func addPhysicsBody(radius: CGFloat) {
        self.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        self.physicsBody!.affectedByGravity = false
        self.physicsBody!.categoryBitMask = 0b0010
        self.physicsBody!.contactTestBitMask = 0b0001
        self.physicsBody!.collisionBitMask = 0
    }
}
