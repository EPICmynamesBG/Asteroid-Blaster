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
    let missileSpeed:CGFloat = 600;
    private var lastFireTime = NSDate()
    private var cannonAnimationFrames = [SKTexture]()
    private let defaultButton = "AsteroidBlasterButton"
    private let defaultButtonTap = "AsteroidBlasterButton_click"
    var deviceResolution:String!
    
    init (scene: GameScene){
        self.screenWidth = scene.frame.size.width
        self.screenHeight = scene.frame.size.height
        
        if (self.screenHeight > 1000){
            self.deviceResolution = "@3x"
        } else {
            self.deviceResolution = "@2x"
        }
        
    }
    
    /* ------------ GAME LOGO -------- */
    
    func getLogo() -> SKSpriteNode{
        let logo = SKSpriteNode(imageNamed: "asteroidBlasterLogo")
        logo.position = CGPoint(x: self.screenWidth/2, y: self.screenHeight - logo.size.height / 2 - 32)
        logo.zPosition = 5
        if (self.deviceResolution == "@3x"){
            logo.setScale(1.5)
        }
        return logo
    }
    
    /* ------------ GAME BACKGROUND -------- */
    
    func getBackground() -> SKSpriteNode {
        let backgroundImage = SKSpriteNode(imageNamed: "background")
        backgroundImage.position = CGPointMake(self.screenWidth / 2, self.screenHeight / 2)
        backgroundImage.size = CGSizeMake(self.screenWidth, self.screenHeight)
        backgroundImage.zPosition = 0
        
        return backgroundImage
    }
    
    /* ------------ GAME CANNON -------- */
    
    func createCannon() -> SKSpriteNode {
        let cannonAtlas = SKTextureAtlas(named: "Cannon")
        var motionFrames = [SKTexture]()
        let numImages = cannonAtlas.textureNames.count / 3
        for (var i = 1; i <= numImages; i++){
            let cannonTextureName = "launcher_cannon.\(i)\(self.deviceResolution).png"
            motionFrames.append(cannonAtlas.textureNamed(cannonTextureName))
        }
        let firstFrame = motionFrames[10]
        let cannon = SKSpriteNode(texture: firstFrame)
        let yLoc = cannon.size.height / 2
        cannon.position = CGPoint(x:(self.screenWidth / 2), y: yLoc)
        cannon.name = "Cannon"
        cannon.zPosition = 2
        if (self.deviceResolution == "@3x"){
            cannon.setScale(1.5)
        }
        self.cannonAnimationFrames = motionFrames
        
        return cannon
    }
    
    func rotateCannonToAngle(angle: CGFloat, direction: Int) -> SKTexture{
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
        return self.cannonAnimationFrames[frame]
    }

    /* ------------ GAME ASTEROIDS -------- */

    func createAsteroid() -> (asteroid: SKSpriteNode, animationFrames: [SKTexture]){
        let asteroidAtlas = SKTextureAtlas(named: "Asteroid")
        var motionFrames = [SKTexture]()
        let numImages = asteroidAtlas.textureNames.count / 3
        for (var i = 1; i <= numImages; i++){
            let textureName = "asteroid.\(i)\(self.deviceResolution).png"
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
        if (self.deviceResolution == "@3x"){
            asteroid.setScale(4.0)
        }
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
    
    /* ------------ GAME EXPLOSIONS -------- */
    
    func createExplosionAtPoint(point: CGPoint) -> SKSpriteNode {
        let explosionAtlas = SKTextureAtlas(named: "Explosion")
        var motionFrames = [SKTexture]()
        let numImages = explosionAtlas.textureNames.count / 3
        for (var i = 1; i <= numImages; i++){
            let textureName = "explosion.\(i)\(self.deviceResolution).png"
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
        if (self.deviceResolution == "@3x"){
            explosion.setScale(1.5)
        }
        return explosion
    }
    
    /* ------------ GAME MISSILES -------- */
    
    private func createMissile() -> SKSpriteNode {
        let missile = SKSpriteNode(imageNamed: "missile")
        missile.position = CGPoint(x: self.screenWidth / 2, y: 0)
        missile.zPosition = 1
        missile.userData = ["UUID": self.missileUUID++]
        if (self.deviceResolution == "@3x"){
            missile.setScale(1.5)
        }
        return missile
    }
    
    func fireMissileTowardsPoint(touchLocation: CGPoint) -> (missile: SKSpriteNode, action: SKAction, fireAngle: CGFloat, direction: Int)? {
        //Limit fire rate to each 1/4 second
        let currentTime = NSDate()
        if (currentTime.timeIntervalSinceDate(self.lastFireTime) < 0.25){
            return nil
        }
        
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
        self.lastFireTime = NSDate()
        return (missile, action, fireAngle, direction)
    }
    
    /* ------------ MISSILE LOGIC -------- */
    
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
    
    /* ------------ GAME BUTTONS -------- */
    
    func createButton(text: String, withScale scale: CGFloat, atPoint point: CGPoint) -> SKButton {
        let button = SKButton(defaultButtonImage: self.defaultButton, onTapButtonImage: self.defaultButtonTap, buttonText: text)
        button.zPosition = 5
        button.setScale(scale)
        button.position = point
        button.name = "\(text)Button"
        if (self.deviceResolution == "@3x"){
            button.setScale(1.1)
        }
        return button
    }
    
    /* ------------ GAME LABELS -------- */
    
    func createLabel(text: String, withFontSize fontSize: CGFloat, atPosition position: CGPoint) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = "Chalkduster"
        label.fontSize = fontSize
        label.fontColor = UIColor.whiteColor()
        label.position = position
        label.zPosition = 1
        return label
    }
    
    func createLabel(text: String, withFontSize fontSize: CGFloat, atPosition position: CGPoint, withZPosition zPos: CGFloat) -> SKLabelNode {
        let label = self.createLabel(text, withFontSize: fontSize, atPosition: position)
        label.zPosition = zPos
        return label
    }
}
