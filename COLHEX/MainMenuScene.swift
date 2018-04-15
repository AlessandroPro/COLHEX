//
//  MainMenuScene.swift
//  COLHEX
//
//  Created by Alessandro Profenna on 2017-04-01.
//  Copyright © 2017 Alessandro Profenna. All rights reserved.
//

import SpriteKit
import AVFoundation

// The first scene that is diplayed when the app is loaded
class MainMenuScene: SKScene {
    
    // Hexagon variables
    var hexWidth: CGFloat
    var hexHeight: CGFloat
    var numRows: CGFloat
    var numCols: CGFloat
    var hexArray: [[Hexagon]]
    
    // Title graphics
    let letterC: SKSpriteNode
    let letterO: SKSpriteNode
    let letterL: SKSpriteNode
    let letterH: SKSpriteNode
    let letterE: SKSpriteNode
    let letterX: SKSpriteNode
    var titleLetters: [SKSpriteNode]
    
    // Text labels
    let singlePlayerButton: SKSpriteNode
    let multiplayerButton: SKSpriteNode
    
    // Flags
    var backPressed: Int
    
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
    
    // Initializes the main menu's sprites, labels, arrays, and logic variables.
    override init(size: CGSize) {
        hexWidth = 0
        hexHeight = 0
        numRows = 0
        numCols = 0
        hexArray = [[Hexagon]]()
        letterC = SKSpriteNode(imageNamed: LETTER_C)
        letterO = SKSpriteNode(imageNamed: LETTER_O)
        letterL = SKSpriteNode(imageNamed: LETTER_L)
        letterH = SKSpriteNode(imageNamed: LETTER_H)
        letterE = SKSpriteNode(imageNamed: LETTER_E)
        letterX = SKSpriteNode(imageNamed: LETTER_X)
        titleLetters = [letterC, letterO, letterL, letterH, letterE, letterX]
        singlePlayerButton = SKSpriteNode(imageNamed: SINGLE_PLAYER)
        multiplayerButton = SKSpriteNode(imageNamed: MULTI_PLAYER)
        backPressed = 0
        backgroundMusicPlayer = AVAudioPlayer()
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
    
    // Sets up the title, labels, and background when the Main Menu Scene is loaded.
    override func didMove(to view: SKView) {
        
        var edgeOffsetX: CGFloat = 3
        let edgeOffsetY: CGFloat = 2
        
        // Hardcoded frame padding for larger devices, and the iPhone X
        if(self.frame.width > IPHONE_MAX_WIDTH) {
            edgeOffsetX = 30
        }
        
        screenMinX = self.frame.minX + edgeOffsetX
        screenMinY = self.frame.minY + edgeOffsetY
        screenMaxX = self.frame.maxX - edgeOffsetX
        screenMaxY = self.frame.maxY - edgeOffsetY
        screenWidth = self.frame.width - (edgeOffsetX*2)
        screenHeight = self.frame.height - (edgeOffsetY*2)
        screenCentreX = self.frame.width/2
        screenCentreY = self.frame.height/2
        backgroundColor = SKColor.init(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        
        // If game was just opened this will be the first scene so the hexArray background must be created
        if(backPressed == 0) {
            createHexArray()

            playBackgroundMusic(filename: BACKGROUND_MUSIC)
            backgroundMusicPlayer.setVolume(1.0, fadeDuration: 3.0)
        }
            // Else, continue using the hexArray from the previous scene
        else {
            for A in 0 ..< hexArray.count {
                for B in 0 ..< hexArray[A].count {
                    hexArray[A][B].removeFromParent()
                    addChild(hexArray[A][B])
                }
            }
        }
        
        // Places the COLHEX title components in their default positions
        var x: CGFloat = 0
        for letter in titleLetters {
            
            letter.xScale = (screenWidth * LETTER_FRAME_WIDTH_RATIO) / letter.frame.height
            letter.yScale = (screenWidth * LETTER_FRAME_WIDTH_RATIO) / letter.frame.height
            letter.anchorPoint = ANCHOR_POINT_CENTER
            letter.zPosition = Z_POS_LEVEL2 + x
            letter.position = CGPoint(x:self.frame.midX, y:self.frame.midY)
            x = x + 1
            addChild(letter)
        }
        
        singlePlayerButton.xScale = (titleLetters[0].frame.width/1.5) / singlePlayerButton.frame.width
        singlePlayerButton.yScale = singlePlayerButton.xScale
        singlePlayerButton.anchorPoint = ANCHOR_POINT_CENTER
        singlePlayerButton.zPosition = Z_POS_LEVEL2
        addChild(singlePlayerButton)
        
        multiplayerButton.xScale = singlePlayerButton.xScale
        multiplayerButton.yScale = singlePlayerButton.xScale
        multiplayerButton.anchorPoint = ANCHOR_POINT_CENTER
        multiplayerButton.zPosition = Z_POS_LEVEL2
        addChild(multiplayerButton)
        
        titleIn(letters: titleLetters)
    }
    
    /**
     Starts the background music and loops it indefinitely.
 
     - parameters:
         - filename: The name of the MP3 music file that is to be looped.
     */
    func playBackgroundMusic(filename: String) {
        let url = Bundle.main.url(forResource: filename, withExtension: nil)
        guard let newURL = url else {
            print("Could not find file: \(filename)")
            return
        }
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: newURL)
            backgroundMusicPlayer.numberOfLoops = -1
            backgroundMusicPlayer.enableRate = true
            backgroundMusicPlayer.prepareToPlay()
            backgroundMusicPlayer.setVolume(0.0, fadeDuration: 0.0)
            backgroundMusicPlayer.play()
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    /**
     Creates a 2D array of Hexagons that fills up the screen.
     */
    func createHexArray() {
        
        // Puts fewer hexagons on screen if the device is an iPhone, puts more if an iPad
        if(self.frame.width < CGFloat(IPHONE_MAX_WIDTH + 100)) {
            hexWidth = screenWidth / IPHONE_MAX_ROW_LENGTH
        }
        else {
            hexWidth = screenWidth / IPAD_MAX_ROW_LENGTH
        }
        hexHeight = hexWidth * HEX_HEIGHT_WIDTH_RATIO
        numCols = (screenWidth / hexWidth)
        numRows = ((screenHeight - hexHeight/2) / (hexHeight*0.75))
        
        // This centers the array of hexagons by offsetting the y position of each
        // hexagon by half the height of leftover space after the last row
        let offset = ((numRows.truncatingRemainder(dividingBy: floor(numRows))*hexHeight)) / 2
        
        var id = 0
        // Creates the background array of hexagons
        for A in 0 ..< Int(numCols)
        {
            var column = [Hexagon]()
            for B in 0 ..< Int(numRows)
            {
                let hex = Hexagon(hexName: BLANK_HEX_SMALL, flareName: BLANK_FLARE_SMALL)
                hex.resize(hexWidth: hexWidth, hexHeight: hexHeight)
                
                //Sets the position of the hexagons in the even numbered rows
                if((CGFloat(B).truncatingRemainder(dividingBy: 2)) < 1) {
                    hex.position = CGPoint(x:screenMinX + CGFloat(A)*hexWidth + hexWidth/2,
                                           y:screenMinY + CGFloat(B)*hexHeight*0.75 + hexHeight/2 + offset)
                }
                    // Sets the position of the hexagons in the odd numbered rows
                else {
                    if(A < Int(numCols) - 1) {
                        hex.position = CGPoint(x:screenMinX + CGFloat(A)*(hex.frame.width)*1.2 + hexWidth,
                                               y:screenMinY + CGFloat(B)*hexHeight*0.75 + hexHeight/2 + offset)
                    }
                    else {
                        continue
                    }
                }
                hex.id = id
                id = id + 1
                addChild(hex)
                column.append(hex)
            }
            hexArray.append(column)
        }
        
        for A in 0 ..< hexArray.count {
            for B in 0 ..< hexArray[A].count {
                hexArray[A][B].growAsBackground()
            }
        }
    }
    
    /**
     Plays a sequence of animations to place the game title and buttons on screen.
 
     - parameters:
         - letters: an array of SKSpriteNodes, each representing a letter of the game title.
     */
    func titleIn(letters: [SKSpriteNode]) {
        
        let letterWidth = letters[0].frame.width * 0.75
        let letterFifth = letters[0].frame.width / 5
        var moves = [SKAction]()
        let xPosC = screenCentreX - letterWidth * 2 - letterWidth/2 - letterFifth
        let nudgeRight = SKAction.moveBy(x: letterFifth, y: 0, duration: 0.2)
        
        var i = 0
        for letter in letters {
            let xOffScreenPosLetter = screenMaxX + letter.frame.width
            let yOffScreenPosLetter = screenCentreY + (screenHeight/10)
            letter.position = CGPoint(x: xOffScreenPosLetter, y: yOffScreenPosLetter)
            
            let xPos = xPosC + (CGFloat(i) * letterWidth)
            let goToPos = SKAction.moveTo(x: xPos, duration: 0.7 - (Double(i) * 0.05))
            let moveLetter = SKAction.run { letter.run(SKAction.sequence([goToPos, nudgeRight])) }
            moves.append(moveLetter)
            i = i + 1
        }
        
        let xOffScreenPosSP = screenCentreX - letterWidth/2
        let xOffScreenPosMP = screenCentreX + letterWidth/2
        let yOffScreenPosButtons = screenMinY - singlePlayerButton.frame.height
        
        singlePlayerButton.position = CGPoint(x: xOffScreenPosSP, y: yOffScreenPosButtons)
        multiplayerButton.position = CGPoint(x: xOffScreenPosMP, y: yOffScreenPosButtons)
        
        let yPosButtons = screenCentreY - (singlePlayerButton.frame.height)
        
        let wait1 = SKAction.wait(forDuration: 0.3)
        let wait2 = SKAction.wait(forDuration: 0.15)
        
        let moveSinglePlayer = SKAction.run{ self.singlePlayerButton.run(SKAction.moveTo(y: yPosButtons, duration: 0.5))}
        let moveMultiPlayer = SKAction.run{ self.multiplayerButton.run(SKAction.moveTo(y: yPosButtons, duration: 0.5))}
        
        let sequenceIn = SKAction.sequence([wait1, moves[0], wait1, moves[1], wait1, moves[2], wait1,
                                            moves[3], wait1, moves[4], wait1, moves[5], moveSinglePlayer,
                                            wait2, moveMultiPlayer])
        
        self.run(sequenceIn)
    }
    
    
    /**
     Plays a sequence of animations to move the game title and buttons offscreen, then switches
     to a new scene.
     
     - parameters:
         - letters: An array of SKSpriteNodes, each representing a letter of the game title
         - action: A string representing the scene to transition to after the UI elements are offscreen
     */
    func titleOut(letters: [SKSpriteNode], action: String) {
        
        let letterFifth = letters[0].frame.width/5
        var moves = [SKAction]()
        let xOffScreenPosLetters = screenMaxX + letters[0].frame.width
        let goOffscreen = SKAction.moveTo(x: xOffScreenPosLetters, duration: 0.3)
        let nudgeLeft = SKAction.moveBy(x: -letterFifth, y: 0, duration: 0.05)
        
        for letter in letters {
            let moveOffScreen = SKAction.run{letter.run(SKAction.sequence([nudgeLeft, goOffscreen]))}
            moves.append(moveOffScreen)
        }
        
        let wait = SKAction.wait(forDuration: 0.15)
        let waitEnd = SKAction.wait(forDuration: 0.5)
        let yOffScreenPosButtons = screenMinY - self.singlePlayerButton.frame.height
        
        let moveSinglePlayer = SKAction.run{ self.singlePlayerButton.run(SKAction.moveTo(y: yOffScreenPosButtons, duration: 0.3))}
        let moveMultiPlayer = SKAction.run{ self.multiplayerButton.run(SKAction.moveTo(y: yOffScreenPosButtons, duration: 0.3))}
        
        
        let sequenceTitleLetters = SKAction.sequence([wait, moves[5], wait, moves[4], wait, moves[3], wait,
                                                      moves[2], wait, moves[1], wait, moves[0], waitEnd])
        let sequenceMenuOptions = SKAction.sequence([moveMultiPlayer, wait, moveSinglePlayer])
        let moveAllOffScreen = SKAction.group([sequenceTitleLetters, sequenceMenuOptions])
        
        let playerSelectScene = PlayerSelectScene(size: self.size)
        playerSelectScene.hexArray = self.hexArray
        playerSelectScene.hexWidth = self.hexWidth
        playerSelectScene.hexHeight = self.hexHeight
        playerSelectScene.numRows = self.numRows
        playerSelectScene.numCols = self.numCols
        playerSelectScene.backgroundMusicPlayer = self.backgroundMusicPlayer
        playerSelectScene.screenMinX = self.screenMinX
        playerSelectScene.screenMinY = self.screenMinY
        playerSelectScene.screenMaxX = self.screenMaxX
        playerSelectScene.screenMaxY = self.screenMaxY
        playerSelectScene.screenWidth = self.screenWidth
        playerSelectScene.screenHeight = self.screenHeight
        playerSelectScene.screenCentreX = self.screenCentreX
        playerSelectScene.screenCentreY = self.screenCentreY
        
        if(action == "multiplayer"){
            self.run(moveAllOffScreen, completion: {
                self.view?.presentScene(playerSelectScene)
            })
        }
        else if(action == "singleplayer"){
            self.run(moveAllOffScreen, completion: {
                playerSelectScene.isMultiplayer = false
                self.view?.presentScene(playerSelectScene)
            })
        }
    }
    
    // Called when the screen is tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = self.atPoint(location)
            let sound = SKAction.playSoundFileNamed(BUTTON_SOUND, waitForCompletion: true)
            
            if (touchedNode == singlePlayerButton) {
                addPulseRing(position: singlePlayerButton.position, scaleFactor: hexWidth, scene: self)
                self.run(sound)
                titleOut(letters: titleLetters, action: "singleplayer")
            }
            else if(touchedNode == multiplayerButton) {
                addPulseRing(position: multiplayerButton.position, scaleFactor: hexWidth, scene: self)
                self.run(sound)
                titleOut(letters: titleLetters, action: "multiplayer")
            }
        }
    }
}
