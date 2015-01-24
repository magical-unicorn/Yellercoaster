//
//  GameScene.swift
//  Yellercoaster
//
//  Created by noliv on 23/01/2015.
//  Copyright (c) 2015 magicalunicorns. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var avancement = 0.0
    var groundBuilt = 0.0
    var groundItems = [SKNode]()
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
//        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
//        myLabel.text = "Hello, World!";
//        myLabel.fontSize = 65;
//        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
//        
//        self.addChild(myLabel)
        let world = self.childNodeWithName("world")!

        let ground = SKNode()
        ground.name = "ground"
        world.addChild(ground)
        self.buildGroundIfNeeded()
    }
    
    func buildGroundIfNeeded() {
        let world = self.childNodeWithName("world")!
        if let ground = world.childNodeWithName("ground") {
            if (self.groundBuilt - self.avancement - 1100.0 <= 0.0) {
                let bezier = self.getBezier(250.0)
                let shape = SKShapeNode(path: bezier.CGPath)
                shape.fillColor = SKColor.redColor()
                shape.strokeColor = SKColor.blackColor()
                shape.position = CGPoint(x: self.groundBuilt, y: 0.0)
                shape.xScale = 1.0
                shape.yScale = 1.0
                let body = SKPhysicsBody(polygonFromPath: bezier.CGPath)
                body.affectedByGravity = false
                body.dynamic = false
                shape.physicsBody = body
                ground.addChild(shape)
                self.groundItems.append(shape)
                self.groundBuilt += 400.0
                if (self.groundItems.count > 8) {
                    let del = self.groundItems.first
                    del?.removeFromParent()
                    self.groundItems.removeAtIndex(0)
                }
                self.buildGroundIfNeeded()
            }
        }
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
        self.buildGroundIfNeeded()
        
        let world = self.childNodeWithName("world")!
        let wagon = world.childNodeWithName("wagon")!
        let ground = world.childNodeWithName("ground")!
        
        let app = UIApplication.sharedApplication().delegate as AppDelegate
        let level = app.audioLevel
        
        let wPos = wagon.position
        
        // wagon.physicsBody?.applyForce(CGVector(dx: 20.0*(300.0 - Double(wPos.x)), dy: 0.0))
        // wagon.physicsBody?.velocity.dx = 300.0 - wPos.x
        // wagon.physicsBody?.applyImpulse(CGVector(dx: 300.0 - Double(wPos.x), dy: 0.0))
        
        let xDiff = CGFloat(20.0*level)
        wagon.physicsBody?.applyForce(CGVector(dx: 140.0 * xDiff, dy: 0.0))
        // ground.position = CGPoint(x: ground.position.x - xDiff, y: ground.position.y)
        self.avancement = Double(wagon.position.x)
        
        let jauge = self.childNodeWithName("jauge") as SKSpriteNode
        let jaugeBG = self.childNodeWithName("jaugeBG") as SKSpriteNode
        jauge.size.height = jaugeBG.size.height * CGFloat(level)
    }
    
    override func didFinishUpdate() {
        self.centerOnNode(self.childNodeWithName("world")!.childNodeWithName("wagon"))
    }
    
    func centerOnNode(node: SKNode?) {
        if let cam = node {
            let camPosInScene = cam.scene?.convertPoint(cam.position, fromNode: cam.parent!)
            if let camPos = camPosInScene {
                cam.parent?.position = CGPoint(x: cam.parent!.position.x - camPos.x + 230.0, y: cam.parent!.position.y - camPos.y + 200.0)
            }
        }
    }
    
    func getBezier(ySize: Double) -> UIBezierPath {
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 400.0, y: 0.0))
        path.addCurveToPoint(CGPoint(x: 200.0, y: ySize), controlPoint1: CGPoint(x: 320.0, y: 0.0), controlPoint2: CGPoint(x: 280.0, y: ySize))
        path.addCurveToPoint(CGPoint(x: 0.0, y: 0.0), controlPoint1: CGPoint(x: 120.0, y: ySize), controlPoint2: CGPoint(x: 80.0, y: 0.0))
        return path
    }
}






