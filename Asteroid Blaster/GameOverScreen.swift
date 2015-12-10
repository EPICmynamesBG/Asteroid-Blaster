//
//  GameOverScreen.swift
//  Asteroid Blaster
//
//  Created by Brandon Groff on 12/7/15.
//  Copyright © 2015 Brandon Groff. All rights reserved.
//

import SpriteKit

class GameOverScreen: SKScene, SKButtonDelegate {
    
    var gameScore: Int!
    var gameObjects: GameObjects!
    var replayButton: SKButton!
    
    
    override func didMoveToView(view: SKView) {
        self.gameObjects = GameObjects(scene: self)
        self.addChild(self.gameObjects.getBackground())
        self.addChild(self.gameObjects.createCannon())
        self.updateHighscore()
        self.createGameLabels()
    }
    
    func updateHighscore(){
        if(SaveManager.updateHighscore(self.gameScore)){
            let newHighscoreLabel = self.gameObjects.createLabel("NEW HIGHSCORE!",
                withFontSize: 32,
                atPosition: CGPoint(x: self.frame.width / 2, y: self.frame.height / 2),
                withZPosition: 5)
            addChild(newHighscoreLabel)
        }
    }
    
    func createGameLabels(){
        let timeLabel = self.gameObjects.createLabel("\(0)",
            withFontSize: 48,
            atPosition: CGPoint(x: 48, y: self.frame.height - 48),
            withZPosition: 5)
        
        let scoreLabel = self.gameObjects.createLabel("\(self.gameScore)",
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
        
        let gameOverLabel = self.gameObjects.createLabel("GAME OVER", withFontSize: 52, atPosition: CGPoint(x: self.size.width / 2, y: 3 * self.size.height / 4), withZPosition: 5)
        
        self.replayButton = self.gameObjects.createButton("Replay", withScale: 1.0, atPoint: CGPoint(x: self.frame.width / 2, y: self.frame.height / 4))
        self.replayButton.delegate = self
        
        self.addChild(timeLabel)
        self.addChild(scoreLabel)
        self.addChild(highScoreLabel.highscoreText)
        self.addChild(highScoreLabel.highscoreValue)
        self.addChild(gameOverLabel)
        self.addChild(self.replayButton)
    }
    
    func buttonTapRelease(sender: SKButton) {
        //replay game
        let nextScene = GameScene(size: self.size)
        let transition = SKTransition.fadeWithColor(UIColor.whiteColor(), duration: 1.0)
        nextScene.scaleMode = .AspectFill
        self.scene?.view?.presentScene(nextScene, transition: transition)
        self.removeFromParent()
    }
    
}