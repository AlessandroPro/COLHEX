//
//  GlobalConstants.swift
//  COLHEX
//
//  Created by Alessandro Profenna on 2017-08-05.
//  Copyright © 2017 Alessandro Profenna. All rights reserved.
//

import Foundation
import SpriteKit

//GLOBAL CONSTANTS

    // Sprite Files
    let BLANK_HEX_LARGE = "hexagonCube2.png"
    let BLANK_FLARE_LARGE = "hexagonWhite2.png"
    let BLANK_HEX_SMALL = "hexagonCube.png"
    let BLANK_FLARE_SMALL = "hexagonWhite.png"
    let LETTER_C = "letterC.png"
    let LETTER_O = "letterO.png"
    let LETTER_L = "letterL.png"
    let LETTER_H = "letterH.png"
    let LETTER_E = "letterE.png"
    let LETTER_X = "letterX.png"
    let SINGLE_PLAYER = "SinglePlayerHex.png"
    let MULTI_PLAYER = "MultiplayerHex.png"
    let START = "Start.png"
    let BACK = "Back.png"
    let PLAYERS = "PlayersHex.png"
    let PULSE_RING = "PulseRing.png"
    let MAIN_MENU = "MainMenuHex.png"
    let PLAY_AGAIN = "PlayAgainHex.png"
    let COUNTDOWN_3 = "3Hex.png"
    let COUNTDOWN_2 = "2Hex.png"
    let COUNTDOWN_1 = "1Hex.png"
    let READY = "ReadyHex.png"
    let COUNTDOWN_START = "StartHex.png"
    let COUNTDOWN_FINISH = "FinishHex.png"
    let HELP_MULTIPLAYER = "HelpMultiPlayer.png"
    let HELP_SINGLEPLAYER = "HelpSinglePlayer.png"
    let HELP_GAMEPLAY = "HelpGameplay.png"
    let HELP = "helpHex.png"

    // Sound Files
    let SELECT_PLAYER_SOUND = "selectColour.mp3"
    let DESELECT_PLAYER_SOUND = "deselectPlayer.mp3"
    let BACKGROUND_MUSIC = "backgroundMusicLoop.mp3"
    let BACKGROUND_MUSIC_FAST = "backgroundMusicFast.mp3"
    let BUTTON_SOUND = "button.mp3"
    let COUNTDOWN_SOUND = "countdown321.mp3"
    let COUNTDOWN_SOUND_END = "countdownOver.mp3"



    // Label Properties
    let DEFAULT_FONT = "Arial-BoldMT"

    // Hexagon Properties
    let IPHONE_MAX_ROW_LENGTH: CGFloat = 17
    let IPAD_MAX_ROW_LENGTH: CGFloat = 21
    let IPHONE_MAX_WIDTH: CGFloat = 800
    let HEX_SCALE_FACTOR: CGFloat = 1.2
    let LETTER_FRAME_WIDTH_RATIO: CGFloat = 0.18
    let HEX_HEIGHT_WIDTH_RATIO: CGFloat = 2/sqrt(3.0)
    let HEX_PHYSICS_BODY_RADIUS_FACTOR: CGFloat = 0.5
    let FLARE_EDGE: CGFloat = 1.0
    let ANCHOR_POINT_CENTER = CGPoint(x: 0.5, y: 0.5)
    let DEFAULT_HEX_COLOUR_BLEND_FACTOR: CGFloat = 0.8

    // Rendering Properties
    let Z_POS_NEGATIVE: CGFloat = -1
    let Z_POS_LOWEST: CGFloat = 0
    let Z_POS_LEVEL1: CGFloat = 10
    let Z_POS_LEVEL2: CGFloat = 20
    let Z_POS_LEVEL3: CGFloat = 30
    let Z_POS_HIGHEST: CGFloat = 40

    /**
     Adds a white ring to the given scene that quickly grows and fades
     at the given position. This is used to indicate the location on screen
     that a player has touched.
 
     - parameters:
         - position: The CGPoint where the ring will appear
         - scaleFactor: The CGFloat used to determine the ring's initial size
         - scene: The SKScene that the ring will be added to
     */
    func addPulseRing(position: CGPoint, scaleFactor: CGFloat, scene: SKScene) {
        let ring = SKSpriteNode(imageNamed: PULSE_RING)
        ring.xScale = (scaleFactor/1.5) / ring.frame.width
        ring.yScale = ring.xScale
        ring.color = SKColor.white
        ring.anchorPoint = ANCHOR_POINT_CENTER
        ring.zPosition = Z_POS_HIGHEST
        ring.colorBlendFactor = 0.2
        ring.position = position
        scene.addChild(ring)
        let pulseGrow = SKAction.scale(by: 6, duration: 0.3)
        let pulseFade = SKAction.fadeOut(withDuration: 0.3)
        let group = SKAction.group([pulseGrow, pulseFade])
        ring.run(group, completion: {
            ring.removeFromParent()
        })
    }

    /**
    Places an SKSpriteNode button in the given scene, with a specified width and location
 
    - parameters:
        - scene: The SKScene that the button will be added to
        - button: The SKSpriteNode button that is to be placed
        - width: The desired CGFloat width of the button
        - xPos: The desired x-position of the botton
        - yPos: The desired y-position of the button
 */
    func placeButton(scene: SKScene, button: SKSpriteNode, width: CGFloat, xPos: CGFloat, yPos: CGFloat) {
        button.xScale = width / button.size.width
        button.yScale = button.xScale
        button.anchorPoint = ANCHOR_POINT_CENTER
        button.zPosition = Z_POS_LEVEL2
        button.position = CGPoint(x: xPos, y: yPos)
        scene.addChild(button)
    }





    



