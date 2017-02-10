//
//  BackgroundScene.swift
//  Weather Go
//
//  Created by Kevin Guo on 2017-02-09.
//  Copyright © 2017 Kevin Guo. All rights reserved.
//

import Foundation
import SpriteKit

class BackgroundScene: SKScene {
    var background = SKSpriteNode(fileNamed: "Rain")!
    
    override func didMove(to view: SKView) {
        
        self.scene?.scaleMode = .resizeFill
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        addChild(background)
    }
}
