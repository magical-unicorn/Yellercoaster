//
//  ScoreScene.swift
//  Yellercoaster
//
//  Created by Biou on 25/01/2015.
//  Copyright (c) 2015 magicalunicorns. All rights reserved.
//

import SpriteKit


class ScoreScene: SKScene {
	override func didMoveToView(view: SKView) {
		let message = self.childNodeWithName("Message")! as SKLabelNode
		let score = self.childNodeWithName("Score")! as SKLabelNode
		let distance = self.childNodeWithName("Distance")! as SKLabelNode
		
		let app = UIApplication.sharedApplication().delegate as AppDelegate
		score.text = String(app.score)
		distance.text = String(app.distance)
		message.text = app.message
		
	}
	override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
		if let scene = SplashScene.unarchiveFromFile("SplashScene") as? SplashScene {
			self.view?.presentScene(scene, transition: SKTransition.flipVerticalWithDuration(0.6))
		}
		
	}
}

