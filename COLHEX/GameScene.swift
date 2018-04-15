//
//  GameScene.swift
//  COLHEX
//
//  Created by Alessandro Profenna on 2017-04-01.
//  Copyright © 2017 Alessandro Profenna. All rights reserved.
//

import SpriteKit
import AVFoundation

// The scene where gameplay occurs
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Hexagon variables
    var hexWidth: CGFloat
    var hexHeight: CGFloat
    var numRows: CGFloat
    var numCols: CGFloat
    var hexArray: [[Hexagon]]
    
    // Timer variables
    var seconds: Int
    var timeInterval: Double
    var timer: Timer
    var timerActive: Bool
    var gameFinished: Bool
    
    // Player variables
    var players: [SKColor:Player]
    var zeroScore: Int
    var hexLabels: [SKSpriteNode]
    var hexLabelWidth: CGFloat

    // Text labels
    let mainMenuButton: SKSpriteNode
    let playAgainButton: SKSpriteNode
    let helpButton: SKSpriteNode
    let helpInfoHex: SKSpriteNode
    let readyButton: SKSpriteNode
    
    // Sound
    var backgroundMusicPlayer: AVAudioPlayer
    var backgroundMusicPlayer2: AVAudioPlayer
    
    //Screen properties
    var screenMinX: CGFloat
    var screenMinY: CGFloat
    var screenMaxX: CGFloat
    var screenMaxY: CGFloat
    var screenWidth: CGFloat
    var screenHeight: CGFloat
    var screenCentreX: CGFloat
    var screenCentreY: CGFloat
    
    // Initializes the game scene's sprites, labels, arrays, and logic variables
    override init(size: CGSize) {
        hexWidth = 0
        hexHeight = 0
        numRows = 0
        numCols = 0
        hexLabelWidth = 0
        players = [:]
        hexArray = [[Hexagon]]()
        seconds = 35
        zeroScore = 0
        hexLabels = [SKSpriteNode]()
        mainMenuButton = SKSpriteNode(imageNamed: MAIN_MENU)
        playAgainButton = SKSpriteNode(imageNamed: PLAY_AGAIN)
        readyButton = SKSpriteNode(imageNamed: READY)
        helpButton = SKSpriteNode(imageNamed: HELP)
        helpInfoHex = SKSpriteNode(imageNamed: HELP_GAMEPLAY)
        gameFinished = false
        timer = Timer.init()
        timeInterval = 0
        timerActive = false
        backgroundMusicPlayer = AVAudioPlayer()
        backgroundMusicPlayer2 = AVAudioPlayer()
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
    
    // Sets up the countdown timer, players, buttons, and hexagon array when the Game Scene is loaded
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        backgroundColor = SKColor.init(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        NotificationCenter.default.addObserver(self, selector: #selector(pauseTimer), name:NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(unpauseTimer), name:NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        backgroundMusicPlayer.setVolume(0.0, fadeDuration: 3.0)
        
        for A in 0 ..< hexArray.count {
            for B in 0 ..< hexArray[A].count {
                let hex = hexArray[A][B]
                hex.removeFromParent()
                hex.removeAllActions()
                hex.resize(hexWidth: hexWidth, hexHeight: hexHeight)
                hex.colorBlendFactor = DEFAULT_HEX_COLOUR_BLEND_FACTOR
                hex.color = SKColor.black
                hex.zPosition = Z_POS_LOWEST
                hex.coloured = false
                hex.addPhysicsBody(radius: hexWidth * HEX_PHYSICS_BODY_RADIUS_FACTOR)
                addChild(hex)
            }
        }
        
        // Randomly scatters each player's colour to 12 different hexagons before the game starts
        for player in players.values {
            var x = 1
            repeat {
                let randomX = Int(arc4random_uniform(UInt32(Int(numCols - 1))))
                let randomY = Int(arc4random_uniform(UInt32(Int(numRows))))
                if(hexArray[randomX][randomY].coloured == false) {
                    let hex = hexArray[randomX][randomY]
                    hex.coloured = true
                    let randomDur = Double((arc4random_uniform(15)) + 5) / 10
                    let wait = SKAction.wait(forDuration: randomDur)
                    self.run(wait) {hex.grow(color: player.colour, hexWidth: self.hexWidth, hexHeight: self.hexHeight)}
                    player.addHexagon(hex: hex)
                    player.score = player.score + 1
                    x = x + 1
                }
            } while(x < 13)
            addChild(player.pulse)
        }
        
        // Places the Ready and Help buttons onscreen, places the Main Menu and Play Again buttons offscreen
        let buttonWidth = hexWidth * 1.5
        let leftOffScreenX = screenMinX + buttonWidth/2 + 15
        let bottomOffScreenY = screenMinY - buttonWidth - 15
        let rightOffScreenX = screenMaxX - buttonWidth/2 - 15
        let bottonOnScreenY = screenMinY + buttonWidth/2 + 15
        placeButton(scene: self, button: mainMenuButton, width: buttonWidth, xPos: leftOffScreenX, yPos: bottomOffScreenY)
        placeButton(scene: self, button: playAgainButton, width: buttonWidth, xPos: rightOffScreenX, yPos: bottomOffScreenY)
        placeButton(scene: self, button: helpButton, width: buttonWidth*0.7, xPos: rightOffScreenX, yPos: bottomOffScreenY)
        placeButton(scene: self, button: readyButton, width: buttonWidth*1.5, xPos: screenCentreX, yPos: screenCentreY)
        
        helpInfoHex.anchorPoint = ANCHOR_POINT_CENTER
        helpInfoHex.position = CGPoint(x: screenCentreX, y: screenCentreY)
        helpInfoHex.zPosition = Z_POS_HIGHEST - 1
        helpInfoHex.alpha = 0
        
        let wait = SKAction.wait(forDuration: 1.0)
        let moveHelpUp = SKAction.moveTo(y: bottonOnScreenY, duration: 0.6)
        helpButton.run(SKAction.sequence([wait,moveHelpUp]), completion: {
            self.helpInfoHex.yScale = (self.screenHeight * 0.96) / self.helpInfoHex.size.height
            self.helpInfoHex.xScale = self.helpInfoHex.yScale
            self.addChild(self.helpInfoHex)
        })
        
        readyButton.alpha = 0
        let readyIn = SKAction.fadeIn(withDuration: 0.5)
        let scaleUp = SKAction.scale(by: 1.25, duration: 0.7)
        let scaleDown = scaleUp.reversed()
        let readyGrow = SKAction.repeatForever(SKAction.sequence([scaleUp,scaleDown]))
        let readySequence = SKAction.sequence([wait, readyIn, readyGrow])
        readyButton.run(readySequence)
    }
    
    /**
     Plays a faster, more upbeat version of the background music during gameplay
     
     - parameters:
     - filename: The name of the audio file that will be played when the game begins
     */
    func playFastBeat(filename: String) {
        let url = Bundle.main.url(forResource: filename, withExtension: nil)
        guard let newURL = url else {
            print("Could not find file: \(filename)")
            return
        }
        do {
            backgroundMusicPlayer2 = try AVAudioPlayer(contentsOf: newURL)
            backgroundMusicPlayer2.numberOfLoops = -1
            backgroundMusicPlayer2.enableRate = true
            backgroundMusicPlayer2.prepareToPlay()
            backgroundMusicPlayer2.play()
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    // Called when the screen is tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNodes = nodes(at: location)
            //let touchedNode = self.atPoint(location)
            for touchedNode in touchedNodes{
                // Expands a pulse from the touched hexagon
                if(touchedNode is Hexagon && (touchedNode as! Hexagon).active) {
                    let player = players[(touchedNode as! Hexagon).color]
                    if(player != nil && !(player?.pulseMoved)!){
                        addPulseRing(position: touchedNode.position, scaleFactor: hexWidth, scene: self)
                        player?.pulse.position = touchedNode.position
                        player?.pulse.resize(pulseWidth: hexWidth, pulseHeight: hexHeight)
                        player?.pulse.addPhysicsBody(radius: hexWidth * 0.6)
                        // Ensures that the player doesn't multitap their own colour
                        player?.pulseMoved = true
                    }
                    break
                }
                else if(gameFinished == true){
                    // Transitions back to the main menu
                    if(touchedNode == mainMenuButton) {
                        addPulseRing(position: mainMenuButton.position, scaleFactor: hexWidth, scene: self)
                        removeScores(action: "MainMenu")
                        break
                    }
                    // Reloads the game scene so that the same game can be played again
                    else if(touchedNode == playAgainButton) {
                        addPulseRing(position: playAgainButton.position, scaleFactor: hexWidth, scene: self)
                        removeScores(action: "PlayAgain")
                        break
                    }
                }
                // Begins the game and starts the 30 second countdown
                else if(touchedNode == readyButton && timerActive == false && helpInfoHex.alpha == 0) {
                        addPulseRing(position: readyButton.position, scaleFactor: hexWidth, scene: self)
                        let readyOut = SKAction.fadeOut(withDuration: 0.5)
                        readyButton.run(readyOut, completion: {
                            self.readyButton.removeFromParent()
                        })
                        let sound = SKAction.playSoundFileNamed(BUTTON_SOUND, waitForCompletion: true)
                        self.run(sound)
                        let moveHelpOffscreen = SKAction.moveTo(y: screenMinY - helpButton.size.height - 15 , duration: 0.6)
                        helpButton.run(moveHelpOffscreen)
                    
                        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
                        timerActive = true
                        break
                }
                // Displays the help info
                else if(touchedNode == helpButton) {
                    addPulseRing(position: helpButton.position, scaleFactor: hexWidth, scene: self)
                    let sound = SKAction.playSoundFileNamed(BUTTON_SOUND, waitForCompletion: true)
                    self.run(sound)
                    let helpFadeIn = SKAction.fadeIn(withDuration: 0.4)
                    helpInfoHex.run(helpFadeIn)
                    break
                }
            }
        }
        for player in players.values {
            player.pulseMoved = false
        }
    }
    
    // Called when a player lifts their finger from the screen
    override  func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(helpInfoHex.alpha > 0) {
            let helpFadeOut = SKAction.fadeOut(withDuration: 0.4)
            helpInfoHex.run(helpFadeOut)
        }
    }
    
    /**
     Called once a second to decrese the countdown timer
     */
    @objc func countdown() {
        switch seconds {
            case 34,3: showCountdown(countdownSpriteName: COUNTDOWN_3)
            case 33,2: showCountdown(countdownSpriteName: COUNTDOWN_2)
            case 32,1: showCountdown(countdownSpriteName: COUNTDOWN_1)
            case 31: showCountdown(countdownSpriteName: COUNTDOWN_START)
            case 30: beginGame()
                     playFastBeat(filename: BACKGROUND_MUSIC_FAST)
            case 0: showCountdown(countdownSpriteName: COUNTDOWN_FINISH)
            case -1: timer.invalidate()
                     timerActive = false
                     self.endGame()
            default: break
        }
        seconds = seconds - 1
    }
    
    /**
     Activates all hexagons in the background array, allowing them to be tapped
     and thus beginning the gameplay
     */
    func beginGame() {
        for A in 0 ..< hexArray.count {
            for B in 0 ..< hexArray[A].count {
                let hex = hexArray[A][B]
                hex.active = true
            }
        }
    }
    
    /**
     Shows one of the countdown sprites to let the players know when there are 3 seconds left before
     the game begins, or 3 seconds left before the game ends.
     
     - parameters:
     - countdownSpriteName: The name of the countdown sprite (3, 2, 1, Start, Finish)
     */
    func showCountdown(countdownSpriteName: String) {
        let countdownSprite = SKSpriteNode(imageNamed: countdownSpriteName)
        countdownSprite.anchorPoint = ANCHOR_POINT_CENTER
        countdownSprite.zPosition = Z_POS_HIGHEST
        countdownSprite.position = CGPoint(x:self.frame.midX, y:self.frame.midY)
        countdownSprite.xScale = 0.01
        countdownSprite.yScale = 0.01
        addChild(countdownSprite)
        
        let countdownGrow = SKAction.scale(by: 15.0, duration: 0.5)
        let wait = SKAction.wait(forDuration: 0.25)
        let countdownFade = SKAction.fadeOut(withDuration: 0.2)
        let fullCountdown = SKAction.sequence([countdownGrow, wait, countdownFade])
        countdownSprite.run(fullCountdown)
        
        if(countdownSpriteName == COUNTDOWN_START || countdownSpriteName == COUNTDOWN_FINISH) {
            let sound = SKAction.playSoundFileNamed(COUNTDOWN_SOUND_END, waitForCompletion: true)
            countdownSprite.run(sound)
        }
        else{
            let sound = SKAction.playSoundFileNamed(COUNTDOWN_SOUND, waitForCompletion: true)
            countdownSprite.run(sound)
        }
    }
    
    /**
    Changes the scores when a particular hexagon changes colour. If the hexagon is black
     then the taker's score is increased by 1. If the hexagon is coloured, then the taker's score
     is increased by 1 and the giver's score is decreased by 1
     
     - parameters:
     - taker: the player's Pulse that changed the hexagon to the player's colour
     - giver: the Hexagon that is changing colour
     */
    func changeScore(taker: Pulse, giver: Hexagon) {
        
        if(taker.color != giver.color) {
            if(giver.color == UIColor.init(red: 0, green: 0, blue: 0, alpha: 1.0)){
                players[taker.color]?.score = players[taker.color]!.score + 1
                players[taker.color]?.addHexagon(hex: giver)
            }
            else {
                players[taker.color]?.score = players[taker.color]!.score + 1
                players[taker.color]?.addHexagon(hex: giver)
                players[giver.color]?.score = players[giver.color]!.score - 1
                players[giver.color]?.removeHexagon(hex: giver)
                if(players[giver.color]?.score == 0) {
                    zeroScore = zeroScore + 1
                }
            }
        }
        
    }
    
    /**
     Verfies if a hexagon toucehd by a pulse is along one of the 6 hexagonal axis' from the pulse's
    origin point.
     
     - parameters:
        - x1: The x position of the hexagon that is being verified
        - y1: The y position of the pulse's origin that touched the hexagon
        - x2: The x position of the hexagon that is being verified
        - y2: The y position of the pulse's origin that touched the hexagon
     
     -returns:
     A Boolean value, true if the hexagon is verified, false otherwise.
     */
    func verifyHex(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) -> Bool {
        
        let adjacent = x2 - x1
        let opposite = y2 - y1
        
        let angleRad = atan(opposite/adjacent)
        let angleDeg = Double(angleRad*180)/Double.pi
        
        // The hexagonal axis' are 60 degress apart from each other
        if(abs(angleDeg) >= 59.9 && abs(angleDeg) <= 60.1) {
            return true
        }
        return false
    }
    
    // Called when a node with a physics body touches another node with a physics body
    func didBegin(_ contact: SKPhysicsContact) {
        
        let bodyBx = contact.bodyB.node!.position.x
        let bodyBy = contact.bodyB.node!.position.y
        let bodyAx = contact.bodyA.node!.position.x
        let bodyAy = contact.bodyA.node!.position.y
        
        if((verifyHex(x1: bodyBx, y1: bodyBy, x2: bodyAx, y2: bodyAy) || bodyBy == bodyAy) && (contact.bodyA.node as! Hexagon).active){
            let hex = contact.bodyA.node as! Hexagon
            let pulse = contact.bodyB.node as! Pulse
            changeScore(taker: pulse, giver: hex)
            hex.grow(color: pulse.color, x: bodyBx, y: bodyBy, hexWidth: hexWidth, hexHeight: hexHeight)
            hex.color = pulse.color
            
        }
    }
    
    /**
     Ends the game, deactivates the background hexagon array, and places the scores for each player on screen
     */
    func endGame() {
        gameFinished = true
        for player in players.values {
            player.pulse.removeFromParent()
        }
        
        for A in 0 ..< hexArray.count {
            for B in 0 ..< hexArray[A].count {
                hexArray[A][B].active = false
                hexArray[A][B].growAsBackground()
            }
        }
        backgroundMusicPlayer2.stop()
        backgroundMusicPlayer.setVolume(1.0, fadeDuration: 3.0)
        placeScores()
        
    }
    
    /**
     Places the scores on screen for each player once the game has ended. The winner's score will
     grow and shrink to show that they've won.
     */
    func placeScores() {
        var sortedPlayers = [Player]()
        for player in players.values {
            sortedPlayers.append(player)
        }
        //sort the players from highest score to lowest score
        for i in 0 ..< sortedPlayers.count {
            var higherPlayer = sortedPlayers[i]
            var removeIndex = i
            for j in i ..< sortedPlayers.count {
                if(sortedPlayers[j].score > higherPlayer.score){
                    higherPlayer = sortedPlayers[j]
                    removeIndex = j
                }
            }
            let removed = sortedPlayers.remove(at: removeIndex)
            sortedPlayers.insert(removed, at: i)
        }
        
        let xPartitionWidth = (screenWidth / CGFloat(sortedPlayers.count + 1))
        
        let highestScore = sortedPlayers[0].score
        var i = 1
        for player in sortedPlayers {

            let score = SKLabelNode(text: "\(player.score)")
            score.fontColor = SKColor.white
            score.fontName = DEFAULT_FONT
            score.fontSize = 220
            score.zPosition = 2
            score.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
            
            
            let hex = Hexagon(hexName: BLANK_HEX_LARGE, flareName: BLANK_FLARE_LARGE)
            hex.color = player.colour
            hex.xScale = (xPartitionWidth/1.5)/hex.size.width
            hex.yScale = hex.xScale
            hex.flare.xScale = (1.0 + (1.0 - hex.xScale)) * 1.32
            hex.flare.yScale = hex.flare.xScale
            hex.addChild(hex.flare)
            hex.colorBlendFactor = 0.6
            hex.zPosition =  Z_POS_HIGHEST - 2*CGFloat(i)
            hexLabelWidth = hex.size.width
            hex.position = CGPoint(x: screenMaxX + hex.size.width, y: screenCentreY)
            
            let darkHex = SKSpriteNode(imageNamed: BLANK_HEX_LARGE)
            darkHex.color = SKColor.black
            darkHex.colorBlendFactor = 0.7
            darkHex.xScale = 0.7
            darkHex.yScale = darkHex.xScale
            
            hex.addChild(darkHex)
            hex.addChild(score)
            hexLabels.append(hex)
            addChild(hex)
            
            
            let move = SKAction.moveTo(x: xPartitionWidth * CGFloat(i) - hex.size.width/5 + screenMinX, duration: 0.6)
            let nudgeRight = SKAction.moveBy(x: hex.size.width/5, y: 0, duration: 0.2)
            
            let scaleUp = SKAction.scale(by: 1.25, duration: 0.7)
            let scaleDown = scaleUp.reversed()
            hex.run(SKAction.sequence([move, nudgeRight]))
            if(player.score == highestScore) {
                hex.run(SKAction.repeatForever(SKAction.sequence([scaleUp,scaleDown])))
            }
            i = i + 1
        }
        let wait = SKAction.wait(forDuration: 1.0)
        let moveTextUp = SKAction.moveTo(y: screenMinY + mainMenuButton.size.height/2 + 15 , duration: 0.6)
        mainMenuButton.run(SKAction.sequence([wait,moveTextUp]))
        playAgainButton.run(SKAction.sequence([wait,moveTextUp]))
    }
    
    /**
     Moves the player scores and buttons offscreen, and transitions to the specified scene
     
     - parameters:
        - action: A string representing the scene to transition to after the UI elements are offscreen.
     */
    func removeScores(action: String) {
        
        var moves = [SKAction]()
        let letterFifth = hexLabelWidth/5
        let xOffScreenPosScores = screenMaxX + hexLabelWidth
        let nudgeLeft = SKAction.moveBy(x: -letterFifth, y: 0, duration: 0.05)
        let goOffscreen = SKAction.moveTo(x: xOffScreenPosScores, duration: 0.3)
        let wait = SKAction.wait(forDuration: 0.15)
        let waitEnd = SKAction.wait(forDuration: 0.5)
        
        for hexLabel in hexLabels {
            let moveOffScreen = SKAction.run{hexLabel.run(SKAction.sequence([nudgeLeft, goOffscreen]))}
            moves.insert(moveOffScreen, at: 0)
            moves.insert(wait, at: 0)
        }
        moves.append(waitEnd)
        
        let buttonOffScreenY = screenMinY - mainMenuButton.size.height
        let moveMainMenu = SKAction.run{ self.mainMenuButton.run(SKAction.moveTo(y: buttonOffScreenY, duration: 0.3))}
        let movePlayAgain = SKAction.run{ self.playAgainButton.run(SKAction.moveTo(y: buttonOffScreenY, duration: 0.3))}

        let sequenceHexLabelsOut = SKAction.sequence(moves)
        let moveAllOffScreen = SKAction.group([sequenceHexLabelsOut, moveMainMenu, movePlayAgain])
        
        for A in 0 ..< hexArray.count {
            for B in 0 ..< hexArray[A].count {
                hexArray[A][B].removeAllActions()
                hexArray[A][B].reset(hexWidth: hexWidth, hexHeight: hexHeight)
            }
        }
        // Transitions to the main menu
        if(action == "MainMenu") {
            let sound = SKAction.playSoundFileNamed(BUTTON_SOUND, waitForCompletion: true)
            self.run(sound)
            self.run(moveAllOffScreen, completion: {
                self.backgroundMusicPlayer.stop()
                self.backgroundMusicPlayer2.stop()
                let mainMenu = MainMenuScene(size: self.size)
                self.view?.presentScene(mainMenu)
            })
        }
        // Restarts the game
        else if(action == "PlayAgain") {
            let sound = SKAction.playSoundFileNamed(BUTTON_SOUND, waitForCompletion: true)
            self.run(sound)
            self.run(moveAllOffScreen, completion: {
                let game = GameScene(size: self.size)
                for player in self.players.values {
                    player.score = 0
                    player.pulse.physicsBody = nil
                }
                game.players = self.players
                game.hexArray = self.hexArray
                game.hexWidth = self.hexWidth
                game.hexHeight = self.hexHeight
                game.numRows = self.numRows
                game.numCols = self.numCols
                game.backgroundMusicPlayer = self.backgroundMusicPlayer
                game.screenMinX = self.screenMinX
                game.screenMinY = self.screenMinY
                game.screenMaxX = self.screenMaxX
                game.screenMaxY = self.screenMaxY
                game.screenWidth = self.screenWidth
                game.screenHeight = self.screenHeight
                game.screenCentreX = self.screenCentreX
                game.screenCentreY = self.screenCentreY
                self.view?.presentScene(game)
            })
        }
    }
    
    /**
     Pauses the game when the the app goes into UIApplicationWillResignActive state. Essentially, if the app
    is moved to the background.
     
     - parameters:
        - notification: The NSNotification sent when the app moves to the background and is therefore inactive
     */
    @objc func pauseTimer(notification : NSNotification) {
        if(timerActive == true && timer.isValid) {
            timer.invalidate()
        }
        
    }
    
    /**
     Unpauses the game when the the app goes into UIApplicationDidBecomeActive state. Essentially, if the app
     becomes full screen again.
     
     - parameters:
        - notification: The NSNotification sent when the app is in full screen and active
     */
    @objc func unpauseTimer(notification : NSNotification) {
        if(timerActive == true) {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
        }
    }
    
    // Called once per frame
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        for player in players.values {
            player.pulse.yScale = player.pulse.yScale + hexWidth/300
            player.pulse.xScale = player.pulse.xScale + hexWidth/300
        }
        // If only one player's colour remains in the game, the game automatically ends
        // and that player wins
        if (zeroScore == players.count - 1 && timerActive) {
            endGame()
            zeroScore = 0
            timer.invalidate()
        }
    }
}

