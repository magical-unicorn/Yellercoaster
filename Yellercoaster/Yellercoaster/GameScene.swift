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
	var maxVelocity : CGFloat = 200.0
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
                let bHeight = 1 + arc4random() % 500
                let bezier = self.getBezier(Double(bHeight))
                let shape = SKShapeNode(path: bezier.CGPath)
                shape.fillColor = SKColor.whiteColor()
                //let texture = SKTexture(imageNamed: "alpha.png")!
                //shape.fillTexture = texture
                shape.setTiledFillTexture("alpha", tileSize: CGSize(width: 32.0, height: 32.0))
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
		// println("XDiff \(xDiff)")
        //wagon.physicsBody?.applyForce(CGVector(dx: 300.0 * xDiff, dy: 0.0))
		let tangent = getTangentVector(wagon.position.x, factor: xDiff);
		var tangentNorm = sqrt((tangent.dx * tangent.dx) + (tangent.dy * tangent.dy))
		println("tangent \(tangent.dx) \(tangent.dy) \(tangentNorm)");

		let vv = wagon.physicsBody?.velocity;
		
		let mass = wagon.physicsBody?.mass;
		let nimpCoef: CGFloat = 1.0;
		
		var squaredVelocity: CGFloat = vv!.dx * vv!.dx + vv!.dy * vv!.dy;
		
		if (squaredVelocity < maxVelocity * maxVelocity) {
		
			/*
			var sign: CGFloat = 1.0;
			if (tangent.dy > 0) {
				sign = 1.0;
			} else {
				sign = -1.0;
			}
			var ortho = CGVector(dx: sign * nimpCoef * mass! * squaredVelocity, dy: -(tangent.dx * mass! * squaredVelocity * nimpCoef / tangent.dy))
			println("ortho \(ortho.dx) \(ortho.dy)");
			var orthoNorm = sqrt((ortho.dx * ortho.dx) + (ortho.dy * ortho.dy))
			if (orthoNorm > 0.000001) {
				ortho.dx = ortho.dx / orthoNorm * tangentNorm;
				ortho.dy = ortho.dy / orthoNorm * tangentNorm;
			} else {
				println("ortho null")
			}
			
			let fleche = self.childNodeWithName("fleche")!
			fleche.zRotation = -CGFloat(atan2f(Float (ortho.dx), Float(ortho.dy)))
			
			println("ortho \(ortho.dx) \(ortho.dy) \(orthoNorm)");
			
			var scalar = tangent.dx * ortho.dx + tangent.dy * ortho.dy
			println("scalar\(scalar)")
			
			
			//var force = CGVector(dx: tangent.dx + ortho.dx, dy: tangent.dy + ortho.dy)
			//println("force \(force.dx) \(force.dy)")
			*/
			wagon.physicsBody?.applyForce(tangent)
		} else {
			println("maxvelocity")
		}
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

	func getTangentVector(x: CGFloat,factor: CGFloat) -> CGVector {
		if (self.groundItems.count < 3) {
			return CGVector(dx: 0.0, dy: 0.0)
		}
		// pour x compris dans l'intervalle d'une shape, on récup la shape
		// NORMALEMENT les shapes sont triées par leur position en x
		var prevNode : SKNode?;
		var nxtNode : SKNode?;
		var coef: CGFloat = 5.0;
		
		for node in self.groundItems {
			//println("position-test: \(node.position.x) for player: \(x)")
			if node.position.x > x {
				nxtNode = node;
				break;
			}
			prevNode = node;
		}

		// println("nxtNode \(nxtNode!.position.x)")
		let shape = nxtNode as SKShapeNode;
		
		var mespoints = BezierHelper.getPointsFromPath(shape.path);
		mespoints.addObject([0.0,0.0])
		// points triés en décroissant
		var leftPoint: CGPoint?;
		var rightPoint: CGPoint?;
		var prevCouple: [NSNumber];
	
		prevCouple = [400.0, 0.0];
		
		for couple in mespoints as [AnyObject]{
			let c = couple as [NSNumber]
			// println("couple \(c[0]) \(c[1])")
			if CGFloat(c[0]) < (x-nxtNode!.position.x+400.0) {
				//
				leftPoint = CGPoint(x: CGFloat (c[0]), y: CGFloat(c[1]))
				rightPoint = CGPoint(x: CGFloat (prevCouple[0]), y: CGFloat (prevCouple[1]))
				break;
			}
			prevCouple = c;
		}
		
		return CGVector(dx: factor * coef * (rightPoint!.x - leftPoint!.x), dy: factor * coef * (rightPoint!.y - leftPoint!.y))
	}
}


extension SKShapeNode {
    func setTiledFillTexture(imageName: String, tileSize: CGSize) {
        let targetDimension = max(self.frame.size.width, self.frame.size.height)
        let targetSize = CGSizeMake(targetDimension, targetDimension)
        let targetRef = UIImage(named: imageName)!.CGImage
        
        UIGraphicsBeginImageContext(targetSize)
        let contextRef = UIGraphicsGetCurrentContext()
        CGContextDrawTiledImage(contextRef, CGRect(origin: CGPointZero, size: tileSize), targetRef)
        let tiledTexture = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.fillTexture = SKTexture(image: tiledTexture)
    }
}



