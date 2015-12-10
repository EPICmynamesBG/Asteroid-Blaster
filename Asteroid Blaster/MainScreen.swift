//
//  MainScreen.swift
//  Asteroid Blaster
//
//  Created by Brandon Groff on 12/7/15.
//  Copyright © 2015 Brandon Groff. All rights reserved.
//

import SpriteKit

class MainScreen: SKScene, SKButtonDelegate {
    
    var gameObjects: GameObjects!
    var logo: SKSpriteNode!
    var startButton: SKButton!
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.gameObjects = GameObjects(scene: self)
        
        
        self.addChild(self.gameObjects.getBackground())
        self.addChild(self.gameObjects.getLogo())
        
        self.addChild(self.gameObjects.createCannon())
        self.createGameLabels()
    }
    
    func createGameLabels(){
        let timeLabel = self.gameObjects.createLabel("\(30)",
            withFontSize: 48,
            atPosition: CGPoint(x: 48, y: self.frame.height - 48),
            withZPosition: 5)
        
        let scoreLabel = self.gameObjects.createLabel("\(0)",
            withFontSize: 48,
            atPosition: CGPoint(x: self.frame.width - 48, y: self.frame.height - 48),
            withZPosition: 5)
        
        var highScoreLabel: (highscoreText: SKLabelNode!, highscoreValue: SKLabelNode!)
        highScoreLabel.highscoreText = self.gameObjects.createLabel("Highscore",
            withFontSize: 16,
            atPosition: CGPoint(x: 48, y: 21),
            withZPosition: 5)
        
        highScoreLabel.highscoreValue = self.gameObjects.createLabel("\(SaveManager.getSavedHighscore())",
            withFontSize: 16,
            atPosition: CGPoint(x: 4, y: 5),
            withZPosition: 5)
        //reposition based on size to align left edges
        highScoreLabel.highscoreValue.position.x = highScoreLabel.highscoreValue.position.x + highScoreLabel.highscoreValue.frame.width / 2
        
        self.startButton = self.gameObjects.createButton("Start", withScale: 1.0, atPoint: CGPoint(x: self.frame.width / 2, y: self.frame.height / 3))
        self.startButton.delegate = self
        
        self.addChild(timeLabel)
        self.addChild(scoreLabel)
        self.addChild(highScoreLabel.highscoreText)
        self.addChild(highScoreLabel.highscoreValue)
        self.addChild(self.startButton)
    }
    
    
    
    /* ---- SKBUTTON DELEGATE METHODS ---- */
    
    func buttonTapRelease(sender: SKButton) {
        let nextScene = GameScene(size: self.size)
        let transition = SKTransition.fadeWithColor(UIColor.whiteColor(), duration: 1.0)
        nextScene.scaleMode = .AspectFill
        self.scene?.view?.presentScene(nextScene, transition: transition)
        self.removeFromParent()
    }
}
