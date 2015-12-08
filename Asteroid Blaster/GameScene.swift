//
//  GameScene.swift
//  Asteroid Blaster
//
//  Created by Brandon Groff on 12/1/15.
//  Copyright (c) 2015 Brandon Groff. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    /* Game items */
    var asteroids = [SKSpriteNode]()
    var missiles = [SKSpriteNode]()
    var explosions = [SKSpriteNode]()
    var cannon = SKSpriteNode()
    var gameObjects: GameObjects!
    var gamePhysics: GamePhysics!
    
    /* Game status */
    var gameScore = 0
    var gameTime = 0
    var startTime: NSDate!
    var gameOver = false
    var lastAsteroid: CFTimeInterval = 0
    
    /* Game labels */
    var timeLabel:SKLabelNode!
    var scoreLabel: SKLabelNode!
    var highScoreLabel: (highscoreText: SKLabelNode!, highscoreValue: SKLabelNode!)
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.gameObjects = GameObjects(scene: self)
        self.gamePhysics = GamePhysics()
        
        self.addChild(self.gameObjects.getBackground())
        
        self.physicsWorld.gravity = GamePhysics.setWorldGravity()
        self.physicsWorld.contactDelegate = self
        
        self.cannon = self.gameObjects.createCannon()
        self.addChild(self.cannon)
        self.createGameLabels()
        
        self.paused = false
        self.setStartTime()
    }
    
    /* ---- GAME SETUP ---- */
    
    func createGameLabels(){
        self.timeLabel = self.gameObjects.createLabel("\(30)",
            withFontSize: 48,
            atPosition: CGPoint(x: 48, y: self.frame.height - 48),
            withZPosition: 5)
        
        self.scoreLabel = self.gameObjects.createLabel("\(self.gameScore)",
            withFontSize: 48,
            atPosition: CGPoint(x: self.frame.width - 48, y: self.frame.height - 48),
            withZPosition: 5)
        
        self.highScoreLabel.highscoreText = self.gameObjects.createLabel("Highscore",
            withFontSize: 16,
            atPosition: CGPoint(x: 48, y: 21),
            withZPosition: 5)
        self.highScoreLabel.highscoreValue = self.gameObjects.createLabel("\(SaveManager.getSavedHighscore())",
            withFontSize: 16,
            atPosition: CGPoint(x: 4, y: 5),
            withZPosition: 5)
        //reposition based on size to align left edges
        self.highScoreLabel.highscoreValue.position.x = self.highScoreLabel.highscoreValue.position.x + self.highScoreLabel.highscoreValue.frame.width / 2
        
        self.addChild(self.timeLabel)
        self.addChild(self.scoreLabel)
        self.addChild(self.highScoreLabel.highscoreText)
        self.addChild(self.highScoreLabel.highscoreValue)
    }
    
    func setStartTime(){
        self.startTime = NSDate()
    }
    
    /* ---- TOUCH HANDLING ---- */
        
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let touchLocation = touch.locationInNode(self)
            if (!self.paused){
                if (!self.gameOver){
                    let MissileData = self.gameObjects.fireMissileTowardsPoint(touchLocation)
                    if (MissileData != nil){
                        let missile = self.gamePhysics.setMissilePhysics(MissileData!.missile)
                        self.addChild(missile)
                        self.missiles.append(missile)
                        missile.runAction(MissileData!.action)
                        if (MissileData!.direction == 0){ //left
                            self.cannon.zRotation = CGFloat(M_PI / 2) - MissileData!.fireAngle
                        } else { //right
                            self.cannon.zRotation = -(CGFloat(M_PI / 2) - MissileData!.fireAngle)
                        }
                        
                    }
                } else {
                    //gameover
                }
            } else {
                //paused
            }
            
        }
    }
    
    /* ---- GAME LOOP ---- */
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if (!self.gameOver){
            updateGameTime()
            //Asteroid generation rate
            if (currentTime - self.lastAsteroid > max(Double(self.gameTime / 14), 0.39) ){
                self.lastAsteroid = currentTime + Double(self.gameTime / 30)
                self.addAsteroid()
            }
            removeOutOfBoundsAsteroids()
            removeOutOfBoundsMissiles()
            updateGameLabels()
        } else {
            //GAME OVER
            displayGameOver()
        }
    }
    
    func updateGameTime(){
        let currentTime = NSDate()
        var difference: NSTimeInterval = 0
        if (self.startTime != nil){
            difference = currentTime.timeIntervalSinceDate(self.startTime)
        }
        
        self.gameTime = Int(31 - difference)
        if (self.gameTime <= 0){
            self.gameOver = true
            self.gameTime = 0
        }
    }
    
    func updateGameLabels() {
        self.timeLabel.text = "\(self.gameTime)"
        self.scoreLabel.text = "\(self.gameScore)"
    }
    
    /* ---- GAME LOOP - CHECKING OBJECT POSITIONS ---- */
    
    func removeOutOfBoundsAsteroids() {
        var indexes = [Int]()
        for (var i = 0; i < self.asteroids.count; i++){
            let asteroid = self.asteroids[i];
            if (asteroid.position.y < 0){
                asteroid.removeFromParent()
                indexes.append(i)
            }
        }
        for (var i=0; i < indexes.count; i++){
            self.asteroids.removeAtIndex(indexes[i])
        }
    }
    
    func removeOutOfBoundsMissiles() {
        var indexes = [Int]()
        for (var i = 0; i < self.missiles.count; i++){
            let missile = self.missiles[i];
            if (missile.position.x < 0 || missile.position.x > self.frame.width || missile.position.y < 0 || missile.position.y > self.frame.height){
                missile.removeFromParent()
                indexes.append(i)
            }
        }
        for (var i=0; i < indexes.count; i++){
            self.missiles.removeAtIndex(indexes[i])
        }
    }

    /* ---- COLLISION HANDLING ---- */
    
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask){
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        var missileIndex = -1;
        var asteroidIndex = -1;

        for (var i=0; i < self.missiles.count; i++){
            let missile = self.missiles[i]
            let missileDict = missile.userData
            for (var j = 0; j < self.asteroids.count; j++){
                let asteroid = self.asteroids[j];
                let asteroidDict = asteroid.userData
                if ((missileDict!["UUID"] as! Int) == (firstBody.node?.userData!["UUID"] as! Int)){
                    if ((asteroidDict!["UUID"] as! Int) == (secondBody.node?.userData!["UUID"] as! Int)){
                        //HIT!!!
                        missile.removeFromParent()
                        asteroid.removeFromParent()
                        self.createExplosionAtPoint(contact.contactPoint)
                        missileIndex = i;
                        asteroidIndex = j;
                        self.gameScore += 1
                    }
                }
            }
        }
        if (missileIndex != -1){
            self.missiles.removeAtIndex(missileIndex)
        }
        if (asteroidIndex != -1){
            self.asteroids.removeAtIndex(asteroidIndex)
        }
    }
    
    /* ---- GENERATING OBJECTS ---- */
    
    func addAsteroid(){
        let asteroidTuple = self.gameObjects.createAsteroid()
        var asteroid = asteroidTuple.asteroid
        
        asteroid = self.gamePhysics.setAsteroidPhysics(asteroid)
        asteroids.append(asteroid)
        self.addChild(asteroid)
    }
    
    func createExplosionAtPoint(point: CGPoint){
        let explosion = self.gameObjects.createExplosionAtPoint(point)
        self.addChild(explosion)
        self.explosions.append(explosion)
    }
    
    /* ---- GAME OVER ---- */
    
    func displayGameOver() {
        self.paused = true
        self.removeChildrenInArray(self.asteroids)
        self.removeChildrenInArray(self.missiles)
        self.removeChildrenInArray(self.explosions)
        
        
    }
    
    
}
