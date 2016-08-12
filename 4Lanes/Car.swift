//
//  Car.swift
//  4Lanes
//
//  Created by Sean Hubbard on 1/2/15.
//  Copyright (c) 2015 That Level LLC. All rights reserved.
//

import SpriteKit

class Car: SKNode {
    var sprite:SKSpriteNode!
    var body:SKPhysicsBody!
    var color: Int!
    var lane: Int!   // 0- left lane, 1- right lane
    var tempSmoke = SKSpriteNode(imageNamed: "SmokeRed")
    
    // Required so XCode doesn't throw warnings
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // car color: 0- red, 1- blue
    init(color: Int) {
        super.init()
        
        // color
        self.color = color
        
        // sprite
        if color == 0 {
            self.sprite = SKSpriteNode(imageNamed: "CarRed");
            self.lane = 0
        }
        else {
            self.sprite = SKSpriteNode(imageNamed: "CarBlue");
            self.lane = 1
        }
        
        // body
        self.body = SKPhysicsBody(rectangleOfSize: self.sprite.size)
        self.body.dynamic = false
        self.body.allowsRotation = true
        self.body.categoryBitMask = kCarIdentifier
        self.body.contactTestBitMask = kShapeCircleIdentifier | kShapeSquareIdentifier
        self.body.collisionBitMask = kShapeCircleIdentifier | kShapeSquareIdentifier
        
        self.sprite.physicsBody = self.body
        self.addChild(self.sprite)
        
        self.smoke()
    }
    
    
    func smoke() {
        var smoke: SKTexture!
        if self.color == 0 {
            smoke = SKTexture(imageNamed: "SmokeRed")
        }
        else {
            smoke = SKTexture(imageNamed: "SmokeBlue")
        }
        
        let burstEmitter = SKEmitterNode()
        burstEmitter.particleTexture = smoke
        
        // position
        let randX = arc4random_uniform(UInt32(Int(self.sprite.size.width)))
        burstEmitter.position = CGPointMake(self.sprite.position.x + self.sprite.size.width/7 - CGFloat(randX/4), self.sprite.position.y - self.sprite.size.height/2 - self.tempSmoke.size.height)
        // rotation
        burstEmitter.particleRotationRange = CGFloat(M_PI_4)
        // properties
        burstEmitter.particleBirthRate = 5.0
        burstEmitter.numParticlesToEmit = 0
        burstEmitter.particleLifetime = 0.7
        burstEmitter.particleSpeed = 10.0
        burstEmitter.xAcceleration = 0.0
        burstEmitter.yAcceleration = -200.0 //-CGFloat(randX/4 * 30)
        burstEmitter.particleAlpha = 0.5
        burstEmitter.particlePositionRange = CGVectorMake(10.0, 0.0)
        
        self.addChild(burstEmitter)
        self.runAction(SKAction.waitForDuration(NSTimeInterval(kChangeLaneSpeed)))
        
//        let delay = SKAction.waitForDuration(NSTimeInterval(kChangeLaneSpeed))
//        let spawn = SKAction.runBlock(self.smoke)
//        let delayThenSpawn = SKAction.sequence([delay, spawn])
//        
//        self.runAction(delayThenSpawn) { () -> Void in
//            burstEmitter.removeFromParent()
//        }
//        self.runAction(delayThenSpawn) { () -> Void in
////            if NSProcessInfo().isOperatingSystemAtLeastVersion(NSOperatingSystemVersion(majorVersion: 9, minorVersion: 0, patchVersion: 0)) {
////                self.delay(0.7, closure: { () -> () in
////                    burstEmitter.removeFromParent()
////                })
////            }
//            
//        }
    }
    
    func changeLane() {
        // need to change to right lane
        var rotateAngle = kCarRotateAngle
        var newMoveToX = self.sprite.size.width
        if self.lane == 0 {
            rotateAngle = rotateAngle * -1
            self.lane = 1
        }
        else {  // need to change to left lane
            newMoveToX = newMoveToX * -1
            self.lane = 0
        }
        
        // animation
        let angle = CGFloat(rotateAngle * M_PI / 180)
        let rotate = SKAction.rotateByAngle(angle, duration: kChangeLaneSpeed)
        let move = SKAction.moveBy(CGVectorMake(newMoveToX * 2, 0), duration: kChangeLaneSpeed)
        let rotateBack = SKAction.rotateByAngle(-angle, duration: kChangeLaneSpeed)
        let sequence = SKAction.sequence([rotate, move, rotateBack])
        self.runAction(sequence)
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}
