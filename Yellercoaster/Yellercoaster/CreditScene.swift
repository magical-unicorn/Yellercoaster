//
//  CreditScene.swift
//  Yellercoaster
//
//  Created by Thibault Milan on 25/01/2015.
//  Copyright (c) 2015 magicalunicorns. All rights reserved.
//

import SpriteKit


class CreditScene: SKScene {

    override func didMoveToView(view: SKView) {
        let bg = SKSpriteNode(imageNamed: "creditBackground.png")
        bg.name = "creditBackground"
        self.addChild(bg)
    }

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */

        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let nodes = self.nodesAtPoint(location)

            for node in nodes as [SKNode] {
                println(node.name)
                if (node.name == "backBtn"){
                    self.gimmeDatMenu()
                }
            }
        }
    }

    func gimmeDatMenu() {
        if let scene = SplashScene.unarchiveFromFile("SplashScene") as? SplashScene {
            self.view?.presentScene(scene, transition: SKTransition.flipVerticalWithDuration(0.6))
        }
    }
}