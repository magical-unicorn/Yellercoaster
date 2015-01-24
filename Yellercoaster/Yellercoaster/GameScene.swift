//
//  GameScene.swift
//  Yellercoaster
//
//  Created by noliv on 23/01/2015.
//  Copyright (c) 2015 magicalunicorns. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
//        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
//        myLabel.text = "Hello, World!";
//        myLabel.fontSize = 65;
//        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
//        
//        self.addChild(myLabel)
        
        let bezier = self.getBezier(400.0)
        
        let shape = SKShapeNode(path: bezier.CGPath)
        shape.fillColor = SKColor.redColor()
        shape.strokeColor = SKColor.blackColor()
        shape.position = CGPoint(x: 200.0, y: 100.0)
        shape.xScale = 1.0
        shape.yScale = 1.0
        
        let body = SKPhysicsBody(polygonFromPath: bezier.CGPath)
        body.affectedByGravity = false
        body.dynamic = false
        shape.physicsBody = body
        self.addChild(shape)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
//            let sprite = SKSpriteNode(imageNamed:"Spaceship")
//            
//            sprite.xScale = 0.5
//            sprite.yScale = 0.5
//            sprite.position = location
//            
//            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
//            
//            sprite.runAction(SKAction.repeatActionForever(action))
//            
//            self.addChild(sprite)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        let wagon = self.childNodeWithName("wagon")!
        let ground = self.childNodeWithName("ground")!
        let app = UIApplication.sharedApplication().delegate as AppDelegate
        let level = app.audioLevel
        
        let xDiff = CGFloat(20.0*level)
        ground.position = CGPoint(x: ground.position.x - xDiff, y: ground.position.y)
    }
    
    func getBezier(ySize: Double) -> UIBezierPath {
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 0.0, y: 0.0))
        path.addCurveToPoint(CGPoint(x: 200.0, y: ySize), controlPoint1: CGPoint(x: 80.0, y: 0.0), controlPoint2: CGPoint(x: 120.0, y: ySize))
        path.addCurveToPoint(CGPoint(x: 400.0, y: 0.0), controlPoint1: CGPoint(x: 280.0, y: ySize), controlPoint2: CGPoint(x: 320.0, y: 0.0))
        return path
    }
}






