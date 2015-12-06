//
//  GameObjects.swift
//  Asteroid Blaster
//
//  Created by Brandon Groff on 12/3/15.
//  Copyright © 2015 Brandon Groff. All rights reserved.
//

import SpriteKit

class GameObjects {
    
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    private var missileUUID: Int = 0
    private var asteroidUUID:Int = 0
    let missileSpeed:CGFloat = 500;
    private var lastFireTime = 0
    
    init (scene: GameScene){
        self.screenWidth = scene.frame.size.width
        self.screenHeight = scene.frame.size.height
    }
    
    func getBackground() -> SKSpriteNode {
        let backgroundImage = SKSpriteNode(imageNamed: "background")
        backgroundImage.position = CGPointMake(self.screenWidth / 2, self.screenHeight / 2)
        backgroundImage.size = CGSizeMake(self.screenWidth, self.screenHeight)
        backgroundImage.zPosition = 0
        return backgroundImage
    }
    
    func createCannon() -> (cannon: SKSpriteNode, animationFrames: [SKTexture]) {
        let cannonAtlas = SKTextureAtlas(named: "Cannon")
        var motionFrames = [SKTexture]()
        let numImages = cannonAtlas.textureNames.count / 3
        for (var i = 1; i <= numImages; i++){
            let cannonTextureName = "launcher_cannon.\(i)@2x.png"
            motionFrames.append(cannonAtlas.textureNamed(cannonTextureName))
        }
        let firstFrame = motionFrames[10]
        let cannon = SKSpriteNode(texture: firstFrame)
        let yLoc = cannon.size.height / 2
        cannon.position = CGPoint(x:(self.screenWidth / 2), y: yLoc)
        cannon.name = "Cannon"
        cannon.zPosition = 2
        //rotateCannon(cannon, animationFrames: motionFrames)
        
        return (cannon, motionFrames)
    }
    
    private func rotateCannon(cannon: SKSpriteNode, animationFrames: [SKTexture]){
        cannon.runAction(SKAction.repeatActionForever(
            SKAction.animateWithTextures(animationFrames,
                timePerFrame: 0.2,
                resize: true,
                restore: true)),
            withKey:"rotatingCannon")
    }

    func createAsteroid() -> (asteroid: SKSpriteNode, animationFrames: [SKTexture]){
        let asteroidAtlas = SKTextureAtlas(named: "Asteroid")
        var motionFrames = [SKTexture]()
        let numImages = asteroidAtlas.textureNames.count / 3
        for (var i = 1; i <= numImages; i++){
            let textureName = "asteroid.\(i)@2x.png"
            motionFrames.append(asteroidAtlas.textureNamed(textureName))
        }
        let firstFrame = motionFrames[0]
        let asteroid = SKSpriteNode(texture: firstFrame)
        let xLoc = CGFloat(arc4random_uniform(UInt32(screenWidth)))
        let yLoc = self.screenHeight + 50
        asteroid.position = CGPoint(x:xLoc, y: yLoc)
        asteroid.setScale(2.0)
        asteroid.name = "asteroid"
        asteroid.zPosition = 1
        asteroid.userData = ["UUID": self.asteroidUUID++]
        
        rotateAsteroid(asteroid, animationFrames: motionFrames)
        
        return (asteroid, motionFrames)
    }
    
    private func rotateAsteroid(asteroid: SKSpriteNode, animationFrames: [SKTexture]){
        asteroid.runAction(SKAction.repeatActionForever(
            SKAction.animateWithTextures(animationFrames,
            timePerFrame: 0.1,
            resize: false,
            restore: true)))
    }
    
    func createExplosionAtPoint(point: CGPoint) -> SKSpriteNode {
        let explosionAtlas = SKTextureAtlas(named: "Explosion")
        var motionFrames = [SKTexture]()
        let numImages = explosionAtlas.textureNames.count / 3
        for (var i = 1; i <= numImages; i++){
            let textureName = "explosion.\(i)@2x.png"
            motionFrames.append(explosionAtlas.textureNamed(textureName))
        }
        let firstFrame = motionFrames[0]
        let explosion = SKSpriteNode(texture: firstFrame)
        explosion.position = point
        explosion.name = "explosion"
        explosion.zPosition = 3
        let explodeAction = SKAction.animateWithTextures(motionFrames, timePerFrame: 0.025, resize: false, restore: true)
        explosion.runAction(explodeAction) { () -> Void in
            explosion.removeFromParent()
        }
        return explosion
    }
    
    func createMissile() -> SKSpriteNode {
        let missile = SKSpriteNode(imageNamed: "missile")
        missile.position = CGPoint(x: self.screenWidth / 2, y: 0)
        missile.zPosition = 1
        missile.userData = ["UUID": self.missileUUID++]
        return missile
    }
    
    func fireMissileTowardsPoint(touchLocation: CGPoint) -> (missile: SKSpriteNode, action: SKAction, fireAngle: CGFloat, direction: Int)? {
        //if (distanct(lastFireTime, currentTime) < 1 sec, abort
        let missile = createMissile()
        let fireAngle = calculateAngle(missile.position, touchPoint: touchLocation)
        if (angleToDegrees(fireAngle) < 28.0){
            //abort fire, angle too shallow
            return nil
        }
        
        let offscreenEndPoint = locationAngleToScreen(fireAngle, touchLocation: touchLocation)
        let travelDist = distance(missile.position, endPoint: offscreenEndPoint)
        let time = travelDist / self.missileSpeed
        let action: SKAction = SKAction.moveTo(CGPoint(x: offscreenEndPoint.x, y: offscreenEndPoint.y), duration: NSTimeInterval(time))
        
        var direction: Int!
        if (offscreenEndPoint.x < missile.position.x){
            direction = 0 //left
            missile.zRotation = CGFloat(M_PI / 2) - fireAngle
        } else {
            direction = 1 // right
            missile.zRotation = -(CGFloat(M_PI / 2) - fireAngle)
        }
        return (missile, action, fireAngle, direction)
    }
    
    private func distance(staticPoint: CGPoint, endPoint: CGPoint) -> CGFloat{
        let screenPoint = CGPointMake(self.screenWidth, staticPoint.y)
        let a = abs(staticPoint.x - screenPoint.x)
        let b = abs(endPoint.y - screenPoint.y)
        let c = sqrt(pow(a, 2) + pow(b, 2))
        return c
    }
    
    private func calculateAngle(cannonPoint: CGPoint, touchPoint: CGPoint) -> CGFloat{
        let a = abs(cannonPoint.x - touchPoint.x) //adjacent (horizontal)
        let b = abs(touchPoint.y) //opposite (vertical)
        let c = sqrt(pow(a, 2) + pow(b, 2)) //hypotenuse
        let angle = asin(b / c) //radians
        return angle
    }
    
    private func locationAngleToScreen (angle: CGFloat, touchLocation: CGPoint) -> CGPoint{
        let cannonPoint = CGPoint(x: self.screenWidth / 2, y: 0)
        var screenPoint: CGPoint!
        if (touchLocation.x < cannonPoint.x){
            screenPoint = CGPoint(x: 0 - 10, y: 0)
        } else {
            screenPoint = CGPoint(x: self.screenWidth + 10, y: 0)
        }
        
        let bottomLen = abs(screenPoint.x - cannonPoint.x)
        let y = tan(angle) * bottomLen
        return CGPoint(x: screenPoint.x, y: y)
    }
    
    func angleToDegrees(angle: CGFloat) -> CGFloat{
        return angle * CGFloat(180.0 / M_PI)
    }
}
