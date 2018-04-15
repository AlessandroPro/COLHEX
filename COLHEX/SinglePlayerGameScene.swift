//
//  SinglePlayerGameScene.swift
//  colhex
//
//  Created by Alessandro Profenna on 2017-09-09.
//  Copyright © 2017 Alessandro Profenna. All rights reserved.
//

import SpriteKit

// The scene where gameplay occurs, specifically for singleplayer
class SinglePlayerGameScene: GameScene {
    
    var cpuPlayers: [Player]
    var singlePlayer: Player
    
    // Initializes the game scene's sprites, labels, arrays, and logic variables
    override init(size: CGSize) {
        cpuPlayers = [Player]()
        singlePlayer = Player(playerColour: SKColor.blue)
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Sets up the singleplayer, CPU player, buttons, and background hexagon array when the Scene is loaded
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        for player in players.values {
            if(player.colour != singlePlayer.colour) {
                cpuPlayers.append(player)
            }
        }
        
    }
    
    /**
     Chooses a hexagon for the CPU player to tap and sets the player's pulse to it
     once its chosen
     
     - parameters:
        - player: The CPU player that is chooing a coloured hexagon to tap
     */
    func touchHexagon(player: Player) {
        if(timer.isValid) {
            let chosenHexID = player.chooseHex()
            if(chosenHexID != -1) {
                let chosenHex = player.hexagons[chosenHexID]
                if(chosenHex != nil && (chosenHex?.active)!) {
                    addPulseRing(position: (chosenHex?.position)!, scaleFactor: hexWidth, scene: self)
                    player.pulse.position = (chosenHex?.position)!
                    player.pulse.resize(pulseWidth: hexWidth, pulseHeight: hexHeight)
                    player.pulse.addPhysicsBody(radius: hexWidth * 0.6)
                }
            }
        }
    }
    
    /**
     Activates all hexagons in the background array, allowing them to be tapped
     and thus beginning the gameplay. Also starts the SKActions that enables the CPU players
     randomly and repeatedly choose hexagons to tap
     */
    override func beginGame() {
        super.beginGame()
        let moreTime = Double((cpuPlayers.count * 3)/10)
        for player in cpuPlayers {
            let action = SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 0.5 + moreTime, withRange: 0.9), SKAction.run {
                self.touchHexagon(player: player)
            }]))
            self.run(action)
        }
    }
    
    
    /**
     Moves the player scores and buttons offscreen, and transitions to the specified scene
     
     - parameters:
     - action: A string representing the scene to transition to after the UI elements are offscreen.
     */
    override func removeScores(action: String) {
        
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
        
        if(action == "MainMenu") {
            let sound = SKAction.playSoundFileNamed(BUTTON_SOUND, waitForCompletion: true)
            self.run(sound)
            backgroundMusicPlayer.stop()
            self.run(moveAllOffScreen, completion: {
                self.backgroundMusicPlayer.stop()
                self.backgroundMusicPlayer2.stop()
                let mainMenu = MainMenuScene(size: self.size)
                self.view?.presentScene(mainMenu)
            })
        }
        else if(action == "PlayAgain") {
            let sound = SKAction.playSoundFileNamed(BUTTON_SOUND, waitForCompletion: true)
            self.run(sound)
            self.run(moveAllOffScreen, completion: {
                let game = SinglePlayerGameScene(size: self.size)
                for player in self.players.values {
                    player.score = 0
                    player.pulse.physicsBody = nil
                }
                game.singlePlayer = self.singlePlayer
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
    
}
