//
//  GamePhysics.swift
//  GamePhysics Blaster
//
//  Created by Brandon Groff on 12/1/15.
//  Copyright © 2015 Brandon Groff. All rights reserved.
//

import SpriteKit

class GamePhysics {
    
    var missileMask: UInt32 = 0x1 << 1
    var asteroidMask: UInt32 = 0x1 << 2
    
    init() {
        
    }
    
    class func setWorldGravity () -> CGVector {
        return CGVectorMake(0, -9.8/8)
    }
    
    
    
    func setAsteroidPhysics (asteroid: SKSpriteNode) -> SKSpriteNode {
        asteroid.physicsBody = SKPhysicsBody(circleOfRadius: asteroid.size.width / 1.95)
        asteroid.physicsBody?.categoryBitMask = self.asteroidMask
        asteroid.physicsBody?.contactTestBitMask = self.missileMask
        asteroid.physicsBody?.dynamic = true
        asteroid.physicsBody?.collisionBitMask = 0
        asteroid.physicsBody?.usesPreciseCollisionDetection = true
        return asteroid
    }

    func setMissilePhysics (missile: SKSpriteNode) -> SKSpriteNode {
        missile.physicsBody = SKPhysicsBody(rectangleOfSize: missile.size)
        missile.physicsBody?.categoryBitMask = self.missileMask
        missile.physicsBody?.contactTestBitMask = self.asteroidMask
        missile.physicsBody?.dynamic = true
        missile.physicsBody?.collisionBitMask = 0
        missile.physicsBody?.usesPreciseCollisionDetection = true
        missile.physicsBody?.affectedByGravity = false
        return missile
    }
    
}
