//
//  GameScene.swift
//  Asteroid Blaster
//
//  Created by Brandon Groff on 12/1/15.
//  Copyright (c) 2015 Brandon Groff. All rights reserved.
//

import SpriteKit


class GameScene: SKScene, SKPhysicsContactDelegate {

    var asteroids = [SKSpriteNode]()
    var missiles = [SKSpriteNode]()
    var cannon = SKSpriteNode()
    var cannonAnimationFrames = [SKTexture]()
    var gameObjects: GameObjects!
    var gamePhysics: GamePhysics!
    var lastAsteroid: CFTimeInterval = 0
    let velocity: CGFloat = 1.0
    
    var gameScore = 0
    var gameTime = 0
    var startTime: NSDate!
    var timeLabel:SKLabelNode!
    var scoreLabel: SKLabelNode!
    var firstTouch = true
    var gameOver = false
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.gameObjects = GameObjects(scene: self)
        self.gamePhysics = GamePhysics()
        self.addChild(self.gameObjects.getBackground())
        
        self.physicsWorld.gravity = GamePhysics.setWorldGravity()
        self.physicsWorld.contactDelegate = self
        
        let cannonTuple = self.gameObjects.createCannon()
        self.cannon = cannonTuple.cannon
        self.cannonAnimationFrames = cannonTuple.animationFrames
        self.addChild(self.cannon)
        self.createGameLabels()
    }
    
    func createGameLabels(){
        self.timeLabel = SKLabelNode(text: "\(30)")
        self.timeLabel.fontName = "Chalkduster"
        self.timeLabel.fontSize = 48
        self.timeLabel.fontColor = UIColor.whiteColor()
        self.timeLabel.position = CGPoint(x: 48, y: self.frame.height - 48)
        self.addChild(self.timeLabel)
    }
    
    func updateGameTime(){
        let currentTime = NSDate()
        var difference: NSTimeInterval = 0
        if (self.startTime != nil){
            difference = currentTime.timeIntervalSinceDate(self.startTime)
        }
        
        self.gameTime = Int(30 - difference)
        if (self.gameTime < 0){
            self.gameOver = true
            self.gameTime = 0
        }
    }
    
    func setStartTime(){
        self.startTime = NSDate()
    }
    
    func addAsteroid(){
        let asteroidTuple = self.gameObjects.createAsteroid()
        var asteroid = asteroidTuple.asteroid
        
        asteroid = self.gamePhysics.setAsteroidPhysics(asteroid)
        asteroids.append(asteroid)
        self.addChild(asteroid)
    }
    
    
    
        
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        if (firstTouch){
            self.firstTouch = false
            self.setStartTime()
        }
        
        
        for touch in touches {
            let touchLocation = touch.locationInNode(self)
            let MissileData = self.gameObjects.fireMissileTowardsPoint(touchLocation)
            if (MissileData != nil){
                let missile = self.gamePhysics.setMissilePhysics(MissileData!.missile)
                self.addChild(missile)
                self.missiles.append(missile)
                missile.runAction(MissileData!.action)
                self.rotateTurretToAngle(self.gameObjects.angleToDegrees(MissileData!.fireAngle), direction: MissileData!.direction) //0=left, 1=right
            }
            
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if (!self.gameOver){
            updateGameTime()
            if (currentTime - self.lastAsteroid > 3 ){
                self.lastAsteroid = currentTime + 1
                self.addAsteroid()
            }
            removeOutOfBoundsAsteroids()
            removeOutOfBoundsMissiles()
            updateGameLabels()
        } else {
            //GAME OVER
        }
    }
    
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
                        self.createExplosionAtPoint(contact.contactPoint)
                        missileIndex = i;
                        asteroidIndex = j;
                        missile.removeFromParent()
                        asteroid.removeFromParent()
                        self.gameScore += 1
                        print(self.gameScore)
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
    
    private func rotateTurretToAngle(angle: CGFloat, direction: Int){
        var frame = 0;
        if (direction == 0){ //left
            if (angle < 30.0){
                frame = 0
            } else if (angle < 34.0){
                frame = 1
            } else if (angle < 43.0){
                frame = 2
            } else if (angle < 49.0){
                frame = 3
            } else if (angle < 57.0){
                frame = 4
            } else if (angle < 63.0){
                frame = 5
            } else if (angle < 69.5){
                frame = 6
            } else if (angle < 77.0){
                frame = 7
            } else if (angle < 80.5){
                frame = 8
            } else if (angle < 84.5){
                frame = 9
            } else {
                frame = 10
            }
        } else { //right
            if (angle < 30.0){
                frame = 20
            } else if (angle < 34.0){
                frame = 19
            } else if (angle < 43.0){
                frame = 18
            } else if (angle < 49.0){
                frame = 17
            } else if (angle < 57.0){
                frame = 16
            } else if (angle < 63.0){
                frame = 15
            } else if (angle < 69.5){
                frame = 14
            } else if (angle < 77.0){
                frame = 13
            } else if (angle < 80.5){
                frame = 12
            } else if (angle < 84.5){
                frame = 11
            } else {
                frame = 10
            }
        }
        self.cannon.texture = self.cannonAnimationFrames[frame]
        //print("Frame \(frame)")
    }
    
    func updateGameLabels() {
        self.timeLabel.text = "\(self.gameTime)"
    }
    
    func createExplosionAtPoint(point: CGPoint){
        let explosion = self.gameObjects.createExplosionAtPoint(point)
        self.addChild(explosion)
    }
    
}
