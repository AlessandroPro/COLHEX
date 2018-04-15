//
//  PlayerSelectScene.swift
//  COLHEX
//
//  Created by Alessandro Profenna on 2017-04-01.
//  Copyright © 2017 Alessandro Profenna. All rights reserved.
//

import SpriteKit
import AVFoundation

// A scene used to select players (single and multi player)
class PlayerSelectScene: SKScene {
    
    // Hexagon variables
    var hexWidth: CGFloat
    var hexHeight: CGFloat
    var playerScaleX: CGFloat
    var playerScaleY: CGFloat
    var numRows: CGFloat
    var numCols: CGFloat
    var hexArray: [[Hexagon]]
    
    // Player options
    var players: [SKColor:Player]
    let hexYellow: Hexagon
    let hexOrange: Hexagon
    let hexRed: Hexagon
    let hexPurple: Hexagon
    let hexBlue: Hexagon
    let hexGreen: Hexagon
    let playerOptions: [Hexagon]
    var offScreenHexPos: [CGPoint]
    let singlePlayerIcon: SKSpriteNode
    var singlePlayerChoice: Hexagon
    var movableIcon: Bool
    var isMultiplayer: Bool
    
    // Text labels
    let startText: SKSpriteNode
    let backText: SKSpriteNode
    let numPlayersHex: SKSpriteNode
    let numPlayers: SKLabelNode
    let helpInfoHex: SKSpriteNode
    let helpButton: SKSpriteNode
    
    // Sound
    var backgroundMusicPlayer: AVAudioPlayer
    
    //Screen properties
    var screenMinX: CGFloat
    var screenMinY: CGFloat
    var screenMaxX: CGFloat
    var screenMaxY: CGFloat
    var screenWidth: CGFloat
    var screenHeight: CGFloat
    var screenCentreX: CGFloat
    var screenCentreY: CGFloat
    
    
    // Initializes the player selection menu's sprites, labels, arrays, and logic variables
    override init(size: CGSize) {
        hexWidth = 0
        hexHeight = 0
        players = [:]
        numRows = 0
        numCols = 0
        hexYellow = Hexagon(hexName: BLANK_HEX_LARGE, flareName: BLANK_FLARE_LARGE)
        hexOrange = Hexagon(hexName: BLANK_HEX_LARGE, flareName: BLANK_FLARE_LARGE)
        hexRed = Hexagon(hexName: BLANK_HEX_LARGE, flareName: BLANK_FLARE_LARGE)
        hexPurple = Hexagon(hexName: BLANK_HEX_LARGE, flareName: BLANK_FLARE_LARGE)
        hexBlue = Hexagon(hexName: BLANK_HEX_LARGE, flareName: BLANK_FLARE_LARGE)
        hexGreen = Hexagon(hexName: BLANK_HEX_LARGE, flareName: BLANK_FLARE_LARGE)
        hexArray = [[Hexagon]]()
        offScreenHexPos = [CGPoint]()
        playerOptions = [hexYellow, hexOrange, hexRed, hexPurple, hexBlue, hexGreen]
        playerScaleX = 0
        playerScaleY = 0
        startText = SKSpriteNode(imageNamed: START)
        backText = SKSpriteNode(imageNamed: BACK)
        numPlayersHex = SKSpriteNode(imageNamed: PLAYERS)
        singlePlayerIcon = SKSpriteNode(imageNamed: PULSE_RING)
        singlePlayerChoice = hexBlue
        movableIcon = false
        backgroundMusicPlayer = AVAudioPlayer()
        isMultiplayer = true
        helpInfoHex = SKSpriteNode(imageNamed: HELP_MULTIPLAYER)
        helpButton = SKSpriteNode(imageNamed: HELP)
        numPlayers = SKLabelNode(text: "\(players.count)")
        screenMinX = 0
        screenMinY = 0
        screenMaxX = 0
        screenMaxY = 0
        screenWidth = 0
        screenHeight = 0
        screenCentreX = 0
        screenCentreY = 0
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Sets up the player options, buttons, and background when the Player Selection Scene is loaded
    override func didMove(to view: SKView) {
        
        backgroundColor = SKColor.init(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        
        for A in 0 ..< hexArray.count {
            for B in 0 ..< hexArray[A].count {
                hexArray[A][B].removeFromParent()
                addChild(hexArray[A][B])
            }
        }
        
        let moveLeft = SKAction.moveBy(x: -7, y: 0, duration: 0.3)
        let moveRight = SKAction.moveBy(x: 7, y: 0, duration: 0.3)
        startText.xScale = hexWidth*2 / startText.size.width
        startText.yScale = startText.xScale
        startText.anchorPoint = ANCHOR_POINT_CENTER
        startText.position = CGPoint(x: screenMaxX + self.startText.size.width, y: screenMaxY/2)
        startText.zPosition = Z_POS_LEVEL2
        addChild(startText)
        startText.run(SKAction.repeatForever(SKAction.sequence([moveRight, moveLeft])))
        
        backText.xScale = startText.xScale
        backText.yScale = startText.xScale
        backText.anchorPoint = ANCHOR_POINT_CENTER
        backText.position = CGPoint(x: screenMinX - self.backText.size.width, y: screenMaxY/2)
        backText.zPosition = Z_POS_LEVEL2
        addChild(backText)
        backText.run(SKAction.repeatForever(SKAction.sequence([moveLeft, moveRight])))
        
        numPlayersHex.anchorPoint = ANCHOR_POINT_CENTER
        numPlayersHex.position = CGPoint(x: screenCentreX, y: screenCentreY)
        numPlayersHex.zPosition = Z_POS_LEVEL2
        
        if(isMultiplayer == false) {
            helpInfoHex.texture = SKTexture(imageNamed: HELP_SINGLEPLAYER)
        }
        helpInfoHex.anchorPoint = ANCHOR_POINT_CENTER
        helpInfoHex.position = CGPoint(x: screenCentreX, y: screenCentreY)
        helpInfoHex.zPosition = Z_POS_HIGHEST - 1
        helpInfoHex.alpha = 0
        
        let hexOffScreen = screenWidth/1.3
        let frameCentreX = screenCentreX
        let frameCentreY = screenCentreY
        let offsetXOffScreen = CGFloat(cos(Double.pi/6))*(hexOffScreen)
        let offsetYOffScreen = CGFloat(sin(Double.pi/6))*(hexOffScreen)
        
        offScreenHexPos.append(CGPoint(x: frameCentreX, y: frameCentreY + hexOffScreen))
        offScreenHexPos.append(CGPoint(x: frameCentreX + offsetXOffScreen, y: frameCentreY + offsetYOffScreen))
        offScreenHexPos.append(CGPoint(x: frameCentreX + offsetXOffScreen, y: frameCentreY - offsetYOffScreen))
        offScreenHexPos.append(CGPoint(x: frameCentreX, y: frameCentreY - hexOffScreen))
        offScreenHexPos.append(CGPoint(x: frameCentreX - offsetXOffScreen, y: frameCentreY - offsetYOffScreen))
        offScreenHexPos.append(CGPoint(x: frameCentreX - offsetXOffScreen, y: frameCentreY + offsetYOffScreen))
        
        var i = 0
        for hex in playerOptions {
            hex.xScale = (screenHeight/10)/hex.size.width
            hex.yScale = hex.xScale
            hex.flare.xScale = (1.0 + (1.0 - hex.xScale)) * 1.3
            hex.flare.yScale = hex.flare.xScale
            hex.colorBlendFactor = 0.6
            hex.zPosition = Z_POS_LEVEL2
            addChild(hex)
            hex.position = offScreenHexPos[i]
            i = i + 1
        }
        playerScaleX = playerOptions[0].xScale
        playerScaleY = playerOptions[0].yScale
        
        playerOptions[0].color = SKColor.yellow
        playerOptions[1].color = SKColor.orange
        playerOptions[2].color = SKColor.red
        playerOptions[3].color = SKColor.purple
        playerOptions[4].color = SKColor.blue
        playerOptions[5].color = SKColor.green
        
        numPlayers.fontColor = SKColor.white
        numPlayers.fontName = DEFAULT_FONT
        numPlayers.fontSize = 300
        numPlayers.zPosition = Z_POS_LEVEL1
        numPlayers.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        numPlayers.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        
        toggleSelectPlayer(hex: playerOptions[1])
        toggleSelectPlayer(hex: playerOptions[4])
        
        numPlayersHex.addChild(numPlayers)
        
        singlePlayerIcon.anchorPoint = ANCHOR_POINT_CENTER
        singlePlayerIcon.zPosition = Z_POS_LEVEL3
        singlePlayerIcon.xScale = playerOptions[4].size.width / singlePlayerIcon.size.width
        singlePlayerIcon.yScale = singlePlayerIcon.xScale
        
        playerSelectionIn()
    }
    
    /**
     Selects or deselects a colour that will be used as a player in the game
     
     - parameters:
        - hex: the coloured Hexagon node that is being selected or deselected
     */
    func toggleSelectPlayer(hex: Hexagon) {
        let scale = SKAction.scale(by: 1.6, duration: 0.2)
        let newPlayer = Player(playerColour: hex.color)
        if (players.removeValue(forKey: newPlayer.colour) == nil) {
            players[newPlayer.colour] = newPlayer
            hex.addFlare()
            hex.run(scale)
            let scaleUp = SKAction.scale(by: 1.13, duration: 0.2)
            let scaleDown = scaleUp.reversed()
            numPlayers.text = "\(players.count)"
            numPlayersHex.run(SKAction.sequence([scaleUp, scaleDown]))
            let sound = SKAction.playSoundFileNamed(SELECT_PLAYER_SOUND, waitForCompletion: true)
            numPlayersHex.run(sound)
        }
        else {
            if(players.count < 2) {
                players[newPlayer.colour] = newPlayer
            }
            else {
                hex.run(scale.reversed())
                hex.removeFlare()
                let scaleDown = SKAction.scale(by: 0.9, duration: 0.2)
                let scaleUp = scaleDown.reversed()
                numPlayers.text = "\(players.count)"
                numPlayersHex.run(SKAction.sequence([scaleDown, scaleUp]))
                let sound = SKAction.playSoundFileNamed(DESELECT_PLAYER_SOUND, waitForCompletion: true)
                numPlayersHex.run(sound)
            }
        }
    }
    
    // Called when the screen is tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNodes = nodes(at: location)
            for touchedNode in touchedNodes {
                // Transistions back to the main menu
                if(touchedNode == backText) {
                    addPulseRing(position: backText.position, scaleFactor: hexWidth, scene: self)
                    playerSelectionOut(action: "back")
                    break
                }
                // Transitions to the game scene
                else if(touchedNode == startText) {
                    addPulseRing(position: startText.position, scaleFactor: hexWidth, scene: self)
                    playerSelectionOut(action: "start")
                    break
                }
                // Selects or deselects the player option colour of the tapped hexagon
                if(touchedNode is Hexagon && (touchedNode as! Hexagon).active){
                    addPulseRing(position: (touchedNode as! Hexagon).position, scaleFactor: hexWidth, scene: self)
                    toggleSelectPlayer(hex: touchedNode as! Hexagon)
                    break
                }
                // Displays help info
                else if(touchedNode == helpButton) {
                    addPulseRing(position: helpButton.position, scaleFactor: hexWidth, scene: self)
                    for hex in playerOptions {
                        hex.active = false
                    }
                    let sound = SKAction.playSoundFileNamed(BUTTON_SOUND, waitForCompletion: true)
                    self.run(sound)
                    let helpFadeIn = SKAction.fadeIn(withDuration: 0.4)
                    helpInfoHex.run(helpFadeIn)
                    break
                }
                // Enables the singleplayer icon to be dragged around
                else if(touchedNode == singlePlayerIcon) {
                    movableIcon = true
                }
            }
        }
    }
    
    // Called when a touched changes position on the screen (used for dragging the singleplayer icon)
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = self.atPoint(location)
            
            if(touchedNode == singlePlayerIcon || movableIcon == true){
                singlePlayerIcon.position = location
            }
        }
    }
    
    // Called when a player lifts their finger from the screen
    override  func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = self.atPoint(location)
            
            // Will assign the single player the colour that the single player icon is on when this is called
            if(touchedNode == singlePlayerIcon || movableIcon == true){
                movableIcon = false
                var newChoice = false
                for playerOption in playerOptions{
                    if(playerOption.contains(location) && playerOption != singlePlayerChoice){
                        singlePlayerIcon.position = playerOption.position
                        if(players[playerOption.color] == nil) {
                            toggleSelectPlayer(hex: playerOption)
                        }
                        //toggleSelectPlayer(hex: singlePlayerChoice)
                        playerOption.active = false
                        singlePlayerChoice.active = true
                        singlePlayerChoice = playerOption
                        newChoice = true
                    }
                }
                if(newChoice == false){
                    singlePlayerIcon.position = singlePlayerChoice.position
                }
            }
            // If the help info is currently being displayed and a player lifts their finger off the
            // screen, then the help info will disappear
            if(helpInfoHex.alpha > 0) {
                for hex in playerOptions {
                    if(hex != singlePlayerChoice) {
                        hex.active = true
                    }
                }
                let helpFadeOut = SKAction.fadeOut(withDuration: 0.4)
                helpInfoHex.run(helpFadeOut)
            }
        }
    }
    
    /**
     Plays a sequence of animations to place the player options on screen, along with the Start, Back,
     and Help buttons.
     */
    func playerSelectionIn() {
        
        let hexRadius = screenHeight/3
        let frameCentreX = screenCentreX
        let frameCentreY = screenCentreY
        let moveDuration = 0.7
        let offsetX = CGFloat(cos(Double.pi/6))*(hexRadius)
        let offsetY = CGFloat(sin(Double.pi/6))*(hexRadius)
        let helpHexHeight = screenHeight*0.96
        let numPlayersHexWidth = hexRadius*0.8
        var hexVertices = [CGPoint]()
        var moveActions = [SKAction]()
        let buttonWidth = hexWidth * 1.5
        let bottomOffScreenY = screenMinY - buttonWidth - 15
        let rightOffScreenX = screenMaxX - buttonWidth/2 - 15
        let bottonOnScreenY = screenMinY + buttonWidth/2 + 15
        
        hexVertices.append(CGPoint(x: frameCentreX, y: frameCentreY + hexRadius))
        hexVertices.append(CGPoint(x: frameCentreX + offsetX, y: frameCentreY + offsetY))
        hexVertices.append(CGPoint(x: frameCentreX + offsetX, y: frameCentreY - offsetY))
        hexVertices.append(CGPoint(x: frameCentreX, y: frameCentreY - hexRadius))
        hexVertices.append(CGPoint(x: frameCentreX - offsetX, y: frameCentreY - offsetY))
        hexVertices.append(CGPoint(x: frameCentreX - offsetX, y: frameCentreY + offsetY))
        
        helpInfoHex.yScale = helpHexHeight / helpInfoHex.size.height
        helpInfoHex.xScale = helpInfoHex.yScale
        addChild(helpInfoHex)
        
        placeButton(scene: self, button: helpButton, width: buttonWidth*0.7, xPos: rightOffScreenX, yPos: bottomOffScreenY)
        
        numPlayersHex.xScale = numPlayersHexWidth / numPlayersHex.size.width
        numPlayersHex.yScale = numPlayersHex.xScale
        numPlayers.position = CGPoint(x: numPlayers.position.x, y: numPlayersHex.size.height * 0.3)
        addChild(numPlayersHex)
        
        var i = 0
        for playerOption in playerOptions {
            let position = hexVertices[i]
            let moveHex = SKAction.run{playerOption.run(SKAction.move(to: position, duration: moveDuration))}
            moveActions.append(moveHex)
            i = i + 1
        }
        
        let backPos = CGPoint(x: (frameCentreX - hexRadius)/2, y: frameCentreY)
        let startPos = CGPoint(x: frameCentreX + hexRadius + (frameCentreX - hexRadius)/2, y: frameCentreY)
        
        
        let runBack = SKAction.run { self.backText.run(SKAction.move(to: backPos, duration: moveDuration))}
        let runStart = SKAction.run { self.startText.run(SKAction.move(to: startPos, duration: moveDuration))}
        let runNumPlayers = SKAction.run { self.numPlayersHex.run(SKAction.fadeIn(withDuration: moveDuration))}
        let runHelp = SKAction.run { self.helpButton.run(SKAction.moveTo(y: bottonOnScreenY, duration: 0.6))}
        
        moveActions.append(runBack)
        moveActions.append(runStart)
        moveActions.append(runNumPlayers)
        moveActions.append(runHelp)

        let group = SKAction.group(moveActions)

        let defaultPlayers = SKAction.run( {
            for hex in self.playerOptions{
                hex.active = true
            }
        })
        
        let sequence = SKAction.sequence([group, defaultPlayers])
        self.run(sequence, completion: {
            if(self.isMultiplayer == false) {
                self.singlePlayerIcon.position = self.singlePlayerChoice.position
                self.hexBlue.active = false
                self.addChild(self.singlePlayerIcon)
            }
        })
    }
    
    
    /**
     Plays a sequence of animations to move the player options and buttons offscreen, then switches
     to a new scene.
     
     - parameters:
        - action: A string representing the scene to transition to after the UI elements are offscreen
     */
    func playerSelectionOut(action: String) {
        
        let frameCentreY = screenCentreY
        let moveDuration = 0.7
        var moveActions = [SKAction]()
        
        var i = 0
        for playerOption in playerOptions {
            let position = offScreenHexPos[i]
            let moveHex = SKAction.run{playerOption.run(SKAction.move(to: position, duration: moveDuration))}
            moveActions.append(moveHex)
            i = i + 1
        }
        
        let backOffScreenPos = CGPoint(x: screenMinX - self.backText.size.width, y: frameCentreY)
        let startOffScreenPos = CGPoint(x: screenMaxX + self.startText.size.width, y: frameCentreY)
        let helpOffScreenY = screenMinY - helpButton.size.height - 15
        
        let runBack = SKAction.run { self.backText.run(SKAction.move(to: backOffScreenPos, duration: 0.7))}
        let runStart = SKAction.run { self.startText.run(SKAction.move(to: startOffScreenPos, duration: 0.7))}
        let runNumPlayers = SKAction.run { self.numPlayersHex.run(SKAction.fadeOut(withDuration: 0.45))}
        let runHelp = SKAction.run { self.helpButton.run(SKAction.moveTo(y: helpOffScreenY, duration: 0.6))}
        
        moveActions.append(runBack)
        moveActions.append(runStart)
        moveActions.append(runNumPlayers)
        moveActions.append(runHelp)
        
        let group = SKAction.group(moveActions)
        
        let turnOff = SKAction.run( {
            for hex in self.playerOptions{
                hex.active = false
            }
        })
        
        let wait1 = SKAction.wait(forDuration: 0.2)
        let wait2 = SKAction.wait(forDuration: 0.7)
        let moveAllOffScreen = SKAction.sequence([wait1, turnOff, group, wait2])
        
        if(action == "start") {
            for A in 0 ..< hexArray.count {
                for B in 0 ..< hexArray[A].count {
                    hexArray[A][B].removeAllActions()
                    hexArray[A][B].reset(hexWidth: hexWidth, hexHeight: hexHeight)
                }
            }
            let sound = SKAction.playSoundFileNamed(BUTTON_SOUND, waitForCompletion: true)
            self.run(sound)
            // If mutliplayer is enabled, the view will transition to a Game Scene
            // If multiplayer is disabled, the view will transition to a Single Player Game Scene
            self.run(moveAllOffScreen, completion: {
                if(self.isMultiplayer == true) {
                    let gameScene = GameScene(size: self.size)
                    gameScene.players = self.players
                    gameScene.hexArray = self.hexArray
                    gameScene.hexWidth = self.hexWidth
                    gameScene.hexHeight = self.hexHeight
                    gameScene.numRows = self.numRows
                    gameScene.numCols = self.numCols
                    gameScene.backgroundMusicPlayer = self.backgroundMusicPlayer
                    gameScene.screenMinX = self.screenMinX
                    gameScene.screenMinY = self.screenMinY
                    gameScene.screenMaxX = self.screenMaxX
                    gameScene.screenMaxY = self.screenMaxY
                    gameScene.screenWidth = self.screenWidth
                    gameScene.screenHeight = self.screenHeight
                    gameScene.screenCentreX = self.screenCentreX
                    gameScene.screenCentreY = self.screenCentreY
                    self.view?.presentScene(gameScene)
                }
                else {
                    let gameScene = SinglePlayerGameScene(size: self.size)
                    gameScene.players = self.players
                    gameScene.hexArray = self.hexArray
                    gameScene.hexWidth = self.hexWidth
                    gameScene.hexHeight = self.hexHeight
                    gameScene.numRows = self.numRows
                    gameScene.numCols = self.numCols
                    gameScene.backgroundMusicPlayer = self.backgroundMusicPlayer
                    gameScene.singlePlayer = self.players[self.singlePlayerChoice.color]!
                    gameScene.screenMinX = self.screenMinX
                    gameScene.screenMinY = self.screenMinY
                    gameScene.screenMaxX = self.screenMaxX
                    gameScene.screenMaxY = self.screenMaxY
                    gameScene.screenWidth = self.screenWidth
                    gameScene.screenHeight = self.screenHeight
                    gameScene.screenCentreX = self.screenCentreX
                    gameScene.screenCentreY = self.screenCentreY
                    self.view?.presentScene(gameScene)
                }
            })
        }
        // If the Back button is pressed, the view transitions to the main menu
        else if(action == "back") {
            let sound = SKAction.playSoundFileNamed(BUTTON_SOUND, waitForCompletion: true)
            self.run(sound)
            self.run(moveAllOffScreen, completion: {
                let mainMenuScene = MainMenuScene(size: self.size)
                mainMenuScene.hexArray = self.hexArray
                mainMenuScene.hexWidth = self.hexWidth
                mainMenuScene.hexHeight = self.hexHeight
                mainMenuScene.numRows = self.numRows
                mainMenuScene.numCols = self.numCols
                mainMenuScene.backgroundMusicPlayer = self.backgroundMusicPlayer
                mainMenuScene.backPressed = 1
                self.view?.presentScene(mainMenuScene)
            })
        }
    }
    
    // Called once per frame
    override func update(_ currentTime: TimeInterval) {
        // Ensures that the single player icon is always positioned on the current single player choice
        if(movableIcon == false) {
            singlePlayerIcon.position = singlePlayerChoice.position
        }
    }

}


