//
//  ScoreScene.swift
//  Yellercoaster
//
//  Created by Biou on 25/01/2015.
//  Copyright (c) 2015 magicalunicorns. All rights reserved.
//

import SpriteKit
import AVFoundation

class ScoreScene: SKScene {
	var audioPlayer: AVAudioPlayer?
	
	override func didMoveToView(view: SKView) {
		var song = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("mort", ofType: "aifc")!)
		var error2:NSError?
		self.audioPlayer = AVAudioPlayer(contentsOfURL: song, error: &error2)
		self.audioPlayer!.numberOfLoops = -1
		self.audioPlayer!.prepareToPlay()
		self.audioPlayer!.play()
		
		let message = self.childNodeWithName("Message")! as SKLabelNode
		let score = self.childNodeWithName("Score")! as SKLabelNode
		let distance = self.childNodeWithName("Distance")! as SKLabelNode
		
		let app = UIApplication.sharedApplication().delegate as AppDelegate
		score.text = "SCORE: " + String(app.score)
		distance.text = "DISTANCE: "+String(app.distance)
		message.text = app.message
		
	}
	override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
		self.audioPlayer!.stop()
		if let scene = SplashScene.unarchiveFromFile("SplashScene") as? SplashScene {
			self.view?.presentScene(scene, transition: SKTransition.flipVerticalWithDuration(0.6))
		}
		
	}
}

