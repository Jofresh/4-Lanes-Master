//
//  Label.swift
//  4Lanes
//
//  Created by Sean Hubbard on 1/2/15.
//  Copyright (c) 2015 That Level LLC. All rights reserved.
//

import SpriteKit

class Label: SKLabelNode {
    init(string: String, color: UIColor, size: CGFloat) {
        // degsinated initializer for SKLabelNode
        super.init()
        
        self.text = string
        self.fontColor = color
        self.fontSize = size
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
