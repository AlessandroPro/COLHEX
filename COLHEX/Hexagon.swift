//
//  Hexagon.swift
//  COLHEX
//
//  Created by Alessandro Profenna on 2017-04-01.
//  Copyright © 2017 Alessandro Profenna. All rights reserved.
//

import SpriteKit

/**
 A hexagon game object that can be clicked on by players.
 Includes a flare, which is simply an outline around the hexagon.
 */
class Hexagon: SKSpriteNode {
    
    let flare: SKSpriteNode
    var active: Bool
    var id: Int
    var coloured: Bool
    let defaultSize: CGSize
    
    /*
     Initializes the hexagon's texture, flare, and logic variables
     */
    init(hexName: String, flareName: String) {
        let texture = SKTexture(imageNamed: hexName)
        flare = SKSpriteNode(imageNamed: flareName)
        active = false
        id = -1
        defaultSize = texture.size()
        coloured = false
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        self.colorBlendFactor = DEFAULT_HEX_COLOUR_BLEND_FACTOR
        self.color = SKColor.black
        self.zPosition = Z_POS_LOWEST
        self.anchorPoint = ANCHOR_POINT_CENTER
        flare.anchorPoint = ANCHOR_POINT_CENTER
        flare.position = self.position
        flare.zPosition = Z_POS_NEGATIVE
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     Adds a flare to the scene as a child node of the hexagon.
     This is rendered as an outline around the hexagon.
     */
    func addFlare() {
        self.flare.removeFromParent()
        self.addChild(flare)
    }
    
    /**
     Removes the child node flare from the hexagon.
     */
    func removeFlare() {
        self.flare.removeFromParent()
    }
    
    /**
     Sets the width and height of the hexagon to the given width and height.
 
     - parameters:
         - hexWidth: The desired width of the hexagon.
         - hexHeight: The desired height of the hexagon.
     */
    func resize(hexWidth: CGFloat, hexHeight: CGFloat) {
        let hexSpriteWidth = defaultSize.width
        let hexSpriteHeight = defaultSize.height
        self.xScale = ((hexWidth/HEX_SCALE_FACTOR) / hexSpriteWidth)
        self.yScale = ((hexHeight/HEX_SCALE_FACTOR) / hexSpriteHeight)
        self.zPosition = Z_POS_LOWEST
        self.flare.xScale = ((self.frame.width/HEX_SCALE_FACTOR) / hexSpriteWidth) + FLARE_EDGE
        self.flare.yScale = ((hexHeight/HEX_SCALE_FACTOR) / hexSpriteHeight) + FLARE_EDGE
    }
    
    /**
     Sets the width and height of the hexagon to the given width and height, and sets the colour
     to black. This is done gradually through an SKAction with a duration of 0.45 seconds.
     
     - parameters:
         - hexWidth: The desired width of the hexagon.
         - hexHeight: The desired height of the hexagon.
     */
    func reset(hexWidth: CGFloat, hexHeight: CGFloat) {
        let size = CGSize(width: hexWidth/HEX_SCALE_FACTOR, height: hexHeight/HEX_SCALE_FACTOR)
        let scaleDown = SKAction.scale(to: size, duration: 0.45)
        let colorDown = SKAction.colorize(with: SKColor.black, colorBlendFactor: DEFAULT_HEX_COLOUR_BLEND_FACTOR, duration: 0.45)
        let group = SKAction.group([scaleDown, colorDown])
        self.zPosition = Z_POS_LOWEST
        self.run(group)
    }
    
    /**
     Gives the Hexagon a circular physics body in order to detect pulses that expand from a player
     touch location.
 
     - parameters:
         - radius: The desired radius of the hexagon's physics body.
     */
    func addPhysicsBody(radius: CGFloat) {
        self.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        self.physicsBody!.affectedByGravity = false
        self.physicsBody!.categoryBitMask = 0b0001
        self.physicsBody!.contactTestBitMask = 0b0010
        self.physicsBody!.collisionBitMask = 0
    }
    
    /**
     Loops the Hexagon in a growing and shrinking animation as part of the background.
     This is purely for aesthetics and involves no interaction or game logic.
     */
    func growAsBackground() {
        
        let randomDur = Double((arc4random_uniform(15)) + 10) / 10
        
        let moveForward = SKAction.run{
            self.zPosition = Z_POS_LEVEL1
        }
        let scaleUp = SKAction.scale(by: 1.25, duration: randomDur)
        let scaleDown = scaleUp.reversed()
        let moveBackward = SKAction.run{
            self.zPosition = Z_POS_LOWEST
        }
        let fullScale = SKAction.sequence([moveForward, scaleUp, scaleDown, moveBackward])
        let colorUp = SKAction.colorize(with: SKColor.black, colorBlendFactor: 0.62, duration: randomDur)
        let colorDown = SKAction.colorize(with: SKColor.black, colorBlendFactor: DEFAULT_HEX_COLOUR_BLEND_FACTOR, duration: randomDur)
        let fullColor = SKAction.sequence([colorUp, colorDown])
        
        let wait = SKAction.wait(forDuration: Double((arc4random_uniform(30)) + 1) / 10)
        var actions = Array<SKAction>()
        
        actions.append(fullScale)
        actions.append(fullColor)
        
        let group = SKAction.group(actions)
        let sequence = SKAction.sequence([wait, group])
        let repeatForever = SKAction.repeatForever(sequence)
        
        self.run(repeatForever)
    }
    
    /**
     Performs a growing and shrinking animation for the hexagon when it interact's with a player's pulse.
 
     - parameters:
         - color: The desired UIColour that the hexagon will be changed to.
         - x: The x-coordinate of the center of the pulse that touched the hexagon.
         - y: The y-coordinate of the center of the pulse that touched the hexagon.
         - hexWidth: The default width of the hexagon.
         - hexHeight: The default height of the hexagon.
     */
    func grow(color: UIColor, x: CGFloat, y: CGFloat, hexWidth: CGFloat, hexHeight: CGFloat) {
        
        self.removeAllActions()
        self.flare.removeFromParent()
        self.resize(hexWidth: hexWidth, hexHeight: hexHeight)
        
        // If this hexagon is the same one that was clicked on by a player (ie, has the same location of the pulse's center),
        // it will shrink instead of grow
        if(self.position.x == x && self.position.y == y) {
            self.zPosition = Z_POS_NEGATIVE
            let scaleDown = SKAction.scale(by: 0.6, duration: 0.1)
            let scaleUp = scaleDown.reversed()
            let fullScale = SKAction.sequence([scaleDown, scaleUp])
            
            let colorUp = SKAction.colorize(with: color, colorBlendFactor: 1.0, duration: 0.1)
            let colorDown = SKAction.colorize(with: color, colorBlendFactor: 0.6, duration: 0.1)
            let fullColor = SKAction.sequence([colorUp, colorDown])

            var actions = Array<SKAction>()
            actions.append(fullScale)
            actions.append(fullColor)
            let group = SKAction.group(actions)
            
            self.run(group)
            
        }
        // In this case, the hexagon is touched by a pulse, not a player directly
        else{
            let addFlare = SKAction.run{
                self.addFlare()
                self.flare.color = color
                self.flare.colorBlendFactor = 0.6
            }
            let scaleUp = SKAction.scale(by: HEX_SCALE_FACTOR, duration: 0.1)
            let scaleDown = scaleUp.reversed()
            let removeFlare = SKAction.run{
                self.removeFlare()
            }
            let fullScale = SKAction.sequence([addFlare, scaleUp, scaleDown, removeFlare])
            
            let colorUp = SKAction.colorize(with: color, colorBlendFactor: 1.0, duration: 0.1)
            let colorDown = SKAction.colorize(with: color, colorBlendFactor: 0.6, duration: 0.1)
            let fullColor = SKAction.sequence([colorUp, colorDown])
            
            let seqUp = SKAction.sequence([SKAction.wait(forDuration: 0.01), SKAction.run {
                self.zPosition = self.zPosition + 1
                }])
            
            let seqDown = SKAction.sequence([SKAction.wait(forDuration: 0.01), SKAction.run {
                self.zPosition = self.zPosition - 1
                }])
            
            let moveUpZ = SKAction.repeat(seqUp, count: 10)
            let moveDownZ = SKAction.repeat(seqDown, count: 10)
            let moveSeqZ = SKAction.sequence([moveUpZ, moveDownZ])
            
            var actions = Array<SKAction>()
            actions.append(fullScale)
            actions.append(fullColor)
            actions.append(moveSeqZ)
            let group = SKAction.group(actions)
            
            self.run(group)
        }
    }
    
    /**
     Performs a growing and shrinking animation on the hexagon, without the flare.
     This function is called only for the hexagons that are randomly selected for each player
     before the game starts.
     
     - parameters:
     - color: The desired UIColour that the hexagon will be changed to.
     - hexWidth: The default width of the hexagon.
     - hexHeight: The default height of the hexagon.
     */
    func grow(color: UIColor, hexWidth: CGFloat, hexHeight: CGFloat) {
        
        self.removeAllActions()
        self.flare.removeFromParent()
        self.resize(hexWidth: hexWidth, hexHeight: hexHeight)
            
        let moveForward = SKAction.run{
            self.zPosition = Z_POS_LEVEL1
        }
        let scaleUp = SKAction.scale(by: HEX_SCALE_FACTOR, duration: 0.2)
        let scaleDown = scaleUp.reversed()
        let moveBackward = SKAction.run{
            self.zPosition = Z_POS_LOWEST
        }
        let fullScale = SKAction.sequence([moveForward, scaleUp, scaleDown, moveBackward])
            
        let colorUp = SKAction.colorize(with: color, colorBlendFactor: 0.6, duration: 0.2)
        let colorDown = SKAction.colorize(with: color, colorBlendFactor: 0.6, duration: 0.2)
        let fullColor = SKAction.sequence([colorUp, colorDown])
            
        var actions = Array<SKAction>()
        actions.append(fullScale)
        actions.append(fullColor)
        let group = SKAction.group(actions)
            
        self.run(group)
    }
}
