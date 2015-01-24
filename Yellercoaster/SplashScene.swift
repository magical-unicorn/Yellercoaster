//
//  GameScene.swift
//  Yellercoaster
//
//  Created by noliv on 23/01/2015.
//  Copyright (c) 2015 magicalunicorns. All rights reserved.
//

import SpriteKit

class SplashScene: SKScene {
    override func didMoveToView(view: SKView) {
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let nodes = self.nodesAtPoint(location)
            
            for node in nodes as [SKNode] {
                if (node.name == "startBtn") {
                    self.letsPlayBaby()
                }
            }
        }
    }
    
    func letsPlayBaby() {
        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            self.view?.presentScene(scene, transition: SKTransition.flipVerticalWithDuration(0.6))
        }

    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        let label = self.childNodeWithName("audioLevel") as SKLabelNode
        
        let app = UIApplication.sharedApplication().delegate as AppDelegate
        let level = app.audioLevel
        let str = NSString(format: "%.6f", level)
        label.text = str
        
    }
}
