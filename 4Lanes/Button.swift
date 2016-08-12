//
//  Button.swift
//  4Lanes
//
//  Created by Sean Hubbard on 1/2/15.
//  Copyright (c) 2015 That Level LLC. All rights reserved.
//

import SpriteKit

class Button: SKSpriteNode {
    
    init(imageNamed: String) {
        let texture = SKTexture(imageNamed: imageNamed)
        // have to call the designated initializer for SKSpriteNode
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.runAction(SKAction.scaleTo(1.3, duration: kButtonFadingSpeed))
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.runAction(SKAction.scaleTo(1.3, duration: kButtonFadingSpeed))
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.runAction(SKAction.scaleTo(1.0, duration: kButtonFadingSpeed))
    }
    
//    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
//        self.runAction(SKAction.scaleTo(1.3, duration: kButtonFadingSpeed))
//    }
//    
//    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
//        self.runAction(SKAction.scaleTo(1.3, duration: kButtonFadingSpeed))
//    }
//    
//    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
//        self.runAction(SKAction.scaleTo(1.0, duration: kButtonFadingSpeed))
//    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}