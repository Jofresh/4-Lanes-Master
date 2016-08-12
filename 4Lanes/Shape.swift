//
//  Shape.swift
//  4Lanes
//
//  Created by Sean Hubbard on 1/2/15.
//  Copyright (c) 2015 That Level LLC. All rights reserved.
//

import SpriteKit

class Shape: SKNode {
    var sprite:SKSpriteNode!
    var body:SKPhysicsBody!
    var color: Int!
    var shape: Int!
    var lane: Int!   // 0- left lane, 1- right lane
    var tempShape = SKSpriteNode(imageNamed: "SquareRed")
    
    // Required so XCode doesn't throw warnings
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // car color: 0- red, 1- blue
    // shape: 0- circle, 1- square
    init(color: Int, shape: Int, lane: Int) {
        super.init()
        
        // color, shape, lane
        self.color = color
        self.shape = shape
        self.lane = lane
        
        // sprite
        if color == 0 {
            if self.shape == 0 {
                self.sprite = SKSpriteNode(imageNamed: "CircleRed");
            }
            else {
                self.sprite = SKSpriteNode(imageNamed: "SquareRed");
            }
            self.lane = 0
        }
        else {
            if self.shape == 0 {
                self.sprite = SKSpriteNode(imageNamed: "CircleBlue");
            }
            else {
                self.sprite = SKSpriteNode(imageNamed: "SquareBlue");
            }
            self.lane = 1
        }
        
        // body
        self.body = SKPhysicsBody(rectangleOfSize: self.sprite.size)
        self.body.dynamic = true
        self.body.allowsRotation = true
        if self.shape == 0 {
            self.body.categoryBitMask = kShapeCircleIdentifier
        }
        else {
            self.body.categoryBitMask = kShapeSquareIdentifier
        }
        self.body.contactTestBitMask = kCarIdentifier
        self.body.collisionBitMask = kCarIdentifier
        
        self.sprite.physicsBody = self.body
        self.addChild(self.sprite)
    }
}







