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
	var maxVelocity : CGFloat = 750.0
    var previousVelocity : CGFloat = 0.0
    var groundItems = [SKNode]()
	let patternWidth:CGFloat = 400.0
	var currentPattern:CGFloat = -1.0;
	var currentJoint:SKPhysicsJointLimit?;
	var wagons = 6;
	var wagon:SKNode?;
	var wagon1:SKNode?;
	var wagon2:SKNode?;
	var wagon3:SKNode?;
	var wagon4:SKNode?;
	var wagon5:SKNode?;
	var joint1:SKPhysicsJointSpring?;
	var joint2:SKPhysicsJointSpring?;
	var joint3:SKPhysicsJointSpring?;
	var joint4:SKPhysicsJointSpring?;
	var joint5:SKPhysicsJointSpring?;
	var lastSpeeds = [CGFloat](count:10, repeatedValue: 0.0);
	let numLastSpeeds = 10;
	var idxLastSpeeds = 0;
	var initSpeeds = false;
	var meanSpeed:CGFloat = 0.0;
	

	
    override func didMoveToView(view: SKView) {
        let world = self.childNodeWithName("world")!

        let ground = SKNode()
        ground.name = "ground"
        world.addChild(ground)
        self.buildGroundIfNeeded()
		
		wagon = world.childNodeWithName("wagon")!
		wagon1 = world.childNodeWithName("wagon1")!
		wagon2 = world.childNodeWithName("wagon2")!
		wagon3 = world.childNodeWithName("wagon3")!
		wagon4 = world.childNodeWithName("wagon4")!
		wagon5 = world.childNodeWithName("wagon5")!

		joint1 = SKPhysicsJointSpring.jointWithBodyA(wagon!.physicsBody, bodyB: wagon1!.physicsBody, anchorA: wagon!.position, anchorB: wagon1!.position)
		self.physicsWorld.addJoint(joint1!)
		joint2 = SKPhysicsJointSpring.jointWithBodyA(wagon1!.physicsBody, bodyB: wagon2!.physicsBody, anchorA: wagon1!.position, anchorB: wagon2!.position)
		self.physicsWorld.addJoint(joint2!)
		joint3 = SKPhysicsJointSpring.jointWithBodyA(wagon2!.physicsBody, bodyB: wagon3!.physicsBody, anchorA: wagon2!.position, anchorB: wagon3!.position)
		self.physicsWorld.addJoint(joint3!)
		joint4 = SKPhysicsJointSpring.jointWithBodyA(wagon3!.physicsBody, bodyB: wagon4!.physicsBody, anchorA: wagon3!.position, anchorB: wagon4!.position)
		self.physicsWorld.addJoint(joint4!)
		joint5 = SKPhysicsJointSpring.jointWithBodyA(wagon4!.physicsBody, bodyB: wagon5!.physicsBody, anchorA: wagon4!.position, anchorB: wagon5!.position)
		self.physicsWorld.addJoint(joint5!)

		
		
		var TimeoutWait = SKAction.waitForDuration(60.0)
		var TimeoutRun = SKAction.runBlock {
			self.findepartie("Temps écoulé")
		}
		world.runAction(SKAction.sequence([TimeoutWait, TimeoutRun]))
		var UpdateSpeedWait = SKAction.waitForDuration(0.2)
		var UpdateSpeedRun = SKAction.runBlock {
			// update last speeds array
			self.lastSpeeds[self.idxLastSpeeds] = self.getSpeed()
			self.idxLastSpeeds = (self.idxLastSpeeds + 1) % self.numLastSpeeds;
			if self.idxLastSpeeds == 9 {
				self.initSpeeds = true
			}
			// compute mean
			for speed in self.lastSpeeds {
				self.meanSpeed +=  (speed);
			}
			self.meanSpeed = self.meanSpeed / CGFloat (self.numLastSpeeds);
			
		}

		world.runAction(SKAction.repeatActionForever(SKAction.sequence([UpdateSpeedWait, UpdateSpeedRun])))
		
		var CheckSpeedWait = SKAction.waitForDuration(4.0)
		var CheckSpeedRun = SKAction.runBlock {
			if self.initSpeeds {
				if self.meanSpeed < 2500 {
					self.larguer1wagon();
				}
			}
		}
		
		world.runAction(SKAction.repeatActionForever(SKAction.sequence([CheckSpeedWait, CheckSpeedRun])))
    }
	

	func larguer1wagon() {
		println("largage wagon \(wagons)")
		if wagons == 6 {
			self.physicsWorld.removeJoint(joint5!)
		} else if wagons == 5 {
			self.physicsWorld.removeJoint(joint4!)
		} else if wagons == 4 {
			self.physicsWorld.removeJoint(joint3!)
		} else if wagons == 3 {
			self.physicsWorld.removeJoint(joint2!)
		} else if wagons == 2 {
			self.physicsWorld.removeJoint(joint1!)
		} else {
			self.findepartie("Plus de wagon !")
		}
		wagons--;
	}
	
	func findepartie(s: String) {
		println("perdu!" + s)
	}
	
    func buildGroundIfNeeded() {

        let world = self.childNodeWithName("world")!
        if let ground = world.childNodeWithName("ground") {
            if (self.groundBuilt - self.avancement - 1100.0 <= 0.0) {
                let bHeight = 1 + arc4random() % 500
                let bezier = self.getBezier(Double(patternWidth),ySize: Double(bHeight))
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
                self.groundBuilt += Double(patternWidth)
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
	
	func getSpeed() -> CGFloat {
		let world = self.childNodeWithName("world")!
		let wagon = world.childNodeWithName("wagon")!
		let vv = wagon.physicsBody?.velocity;
		var squaredVelocity: CGFloat = vv!.dx * vv!.dx + vv!.dy * vv!.dy;
		return squaredVelocity;
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
        
        let xDiff = CGFloat(32.0*level)
		// println("XDiff \(xDiff)")
        //wagon.physicsBody?.applyForce(CGVector(dx: 300.0 * xDiff, dy: 0.0))
		let tangent = getTangentVector(wagon.position.x, factor: xDiff);
		var tangentNorm = sqrt((tangent.dx * tangent.dx) + (tangent.dy * tangent.dy))
		// println("tangent \(tangent.dx) \(tangent.dy) \(tangentNorm)");

		let vv = wagon.physicsBody?.velocity;
		
		let mass = wagon.physicsBody?.mass;
		let nimpCoef: CGFloat = 1.0;
		
		var squaredVelocity: CGFloat = vv!.dx * vv!.dx + vv!.dy * vv!.dy;
		
		if (squaredVelocity < maxVelocity * maxVelocity) {
			var sign: CGFloat = 1.0;
			if (tangent.dy > 0) {
				sign = 1.0;
			} else {
				sign = -1.0;
			}
			var ortho = CGVector(dx: sign * nimpCoef * mass! * squaredVelocity, dy: -(tangent.dx * sign * mass! * squaredVelocity * nimpCoef / tangent.dy))
			// println("ortho \(ortho.dx) \(ortho.dy)");
			var orthoNorm = sqrt((ortho.dx * ortho.dx) + (ortho.dy * ortho.dy))
			if (orthoNorm > 0.000001) {
				ortho.dx = ortho.dx / orthoNorm * tangentNorm;
				ortho.dy = ortho.dy / orthoNorm * tangentNorm;
			} else {
				// println("ortho null")
			}
			
			let fleche = self.childNodeWithName("fleche")!
			fleche.zRotation = self.angleOfVector(tangent)
			
			var scalar = tangent.dx * ortho.dx + tangent.dy * ortho.dy
			// println("scalar\(scalar)")
			
            //wagon.physicsBody?.applyForce(CGVector(dx: ortho.dx * 2.5, dy: ortho.dy * 1.5))
			
			var force = CGVector(dx: tangent.dx + 1.7 * ortho.dx, dy: tangent.dy + 0.8 * ortho.dy)
			//println("force \(force.dx) \(force.dy)")

			wagon.physicsBody?.applyForce(force)
		} else {
			//println("maxvelocity")
		}
        // ground.position = CGPoint(x: ground.position.x - xDiff, y: ground.position.y)
        self.avancement = Double(wagon.position.x)
        
        let jauge = self.childNodeWithName("jauge") as SKSpriteNode
        let jaugeBG = self.childNodeWithName("jaugeBG") as SKSpriteNode
        jauge.size.height = jaugeBG.size.height * CGFloat(level)
        
        for voiture in wagons {
            if (voiture.name != "wagon") {
                self.centripeteTaMere(voiture)
            }
        }
    }
    
    func centripeteTaMere(wagonnet: SKNode) {
        let wPos = wagonnet.position
        
        let xDiff = CGFloat(32.0*0.25)
        
        let tangent = getTangentVector(wagonnet.position.x, factor: xDiff);
        var tangentNorm = sqrt((tangent.dx * tangent.dx) + (tangent.dy * tangent.dy))
        
        let vv = wagonnet.physicsBody?.velocity;
        
        let mass = wagonnet.physicsBody?.mass;
        let nimpCoef: CGFloat = 1.0;
        
        var squaredVelocity: CGFloat = vv!.dx * vv!.dx + vv!.dy * vv!.dy;
        
        if (squaredVelocity < maxVelocity * maxVelocity) {
            var sign: CGFloat = 1.0;
            if (tangent.dy > 0) {
                sign = 1.0;
            } else {
                sign = -1.0;
            }
            var ortho = CGVector(dx: sign * nimpCoef * mass! * squaredVelocity, dy: -(tangent.dx * sign * mass! * squaredVelocity * nimpCoef / tangent.dy))
            // println("ortho \(ortho.dx) \(ortho.dy)");
            var orthoNorm = sqrt((ortho.dx * ortho.dx) + (ortho.dy * ortho.dy))
            if (orthoNorm > 0.000001) {
                ortho.dx = ortho.dx / orthoNorm * tangentNorm;
                ortho.dy = ortho.dy / orthoNorm * tangentNorm;
            }
            
            var scalar = tangent.dx * ortho.dx + tangent.dy * ortho.dy
            
            wagonnet.physicsBody?.applyForce(CGVector(dx: ortho.dx * 2.5, dy: ortho.dy * 2.9))
        }
    }
    
    override func didFinishUpdate() {
        let world = self.childNodeWithName("world")
        let wagon = world?.childNodeWithName("wagon")
        let velocity = pow(wagon!.physicsBody!.velocity.dx,2.0) + pow(wagon!.physicsBody!.velocity.dy,2.0)
//        if (velocity > 2.2) {
//            wagon!.zRotation = self.angleOfVector(wagon!.physicsBody!.velocity)
//        }
        
        for item in wagons {
            self.orientWagon(item)
        }

        // tentative de zoom en fonction de la vélocité
        let prevVelo = previousVelocity
        previousVelocity = velocity
        let filteredVelocity = 0.08 * velocity + 0.92 * prevVelo
        previousVelocity = filteredVelocity
        var scale: CGFloat = 0.9 + filteredVelocity * 0.0000020
        if (scale > 2.15) {
            scale = 2.15
        }
        world?.xScale = scale
        world?.yScale = scale
        self.centerOnNode(self.childNodeWithName("world")!.childNodeWithName("wagon"))
    }
    
    func orientWagon(wag: SKNode) {
        let velocity = pow(wag.physicsBody!.velocity.dx,2.0) + pow(wag.physicsBody!.velocity.dy,2.0)
        if (velocity > 2.2) {
            var direction = wag.physicsBody!.velocity
            if (direction.dx < 0) {
                direction.dx *= -1
            }
            wag.zRotation = self.angleOfVector(direction)
        }
    }
    
    func centerOnNode(node: SKNode?) {
        if let cam = node {
            let camPosInScene = cam.scene?.convertPoint(cam.position, fromNode: cam.parent!)
            if let camPos = camPosInScene {
                cam.parent?.position = CGPoint(x: cam.parent!.position.x - camPos.x + 340.0, y: cam.parent!.position.y - camPos.y + 320.0)
            }
        }
    }
    
    func getBezier(xSize: Double, ySize: Double) -> UIBezierPath {
        let path = UIBezierPath()
        let factor = xSize / 400.0
        path.moveToPoint(CGPoint(x: patternWidth, y: 0.0))
        path.addCurveToPoint(CGPoint(x: 200.0 * factor, y: ySize), controlPoint1: CGPoint(x: 320.0 * factor, y: 0.0), controlPoint2: CGPoint(x: 280.0 * factor, y: ySize))
        path.addCurveToPoint(CGPoint(x: 0.0, y: 0.0), controlPoint1: CGPoint(x: 120.0 * factor, y: ySize), controlPoint2: CGPoint(x: 80.0 * factor, y: 0.0))
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
		let shape = prevNode as SKShapeNode;
		
		var mespoints = BezierHelper.getPointsFromPath(shape.path);
		mespoints.addObject([0.0,0.0])
		// points triés en décroissant
		var leftPoint: CGPoint?;
		var rightPoint: CGPoint?;
		var prevCouple: [NSNumber];
	
		prevCouple = [patternWidth, 0.0];
		
        var foundPoints = false
		for couple in mespoints as [AnyObject]{
			let c = couple as [NSNumber]
			// println("couple \(c[0]) \(c[1])")
            
            if let unwrappedNxtNode = nxtNode {
                if CGFloat(c[0]) < (x - unwrappedNxtNode.position.x + patternWidth) {
                    //
                    leftPoint = CGPoint(x: CGFloat (c[0]), y: CGFloat(c[1]))
                    rightPoint = CGPoint(x: CGFloat (prevCouple[0]), y: CGFloat (prevCouple[1]))
                    foundPoints = true
                    break;
                }
            } else {
                leftPoint = CGPoint(x: CGFloat (c[0]), y: CGFloat(c[1]))
                rightPoint = CGPoint(x: CGFloat (c[0])+3.0, y: CGFloat(c[1]))
                foundPoints = true
                break;
            }
            
			
			prevCouple = c;
		}
        if (!foundPoints) {
            return CGVector(dx: 0.0, dy: 0.0)
        }
		
        var dx = factor * coef * (rightPoint!.x - leftPoint!.x);
        if (dx < 0) {
            dx *= -1
        }
        
		// pour la shape, on récupère
		return CGVector(dx: dx, dy: factor * coef * (rightPoint!.y - leftPoint!.y))
	}
    
    func angleOfVector(vector: CGVector) -> CGFloat {
        return CGFloat(M_PI_2) - atan2((vector.dx), (vector.dy))
        var rawAngle = atan2(Double(vector.dx), Double(vector.dy))
        if (vector.dy < 0 && vector.dx > 0) {
            rawAngle *= -1
            rawAngle += M_PI_2
        } else if (vector.dy < 0 && vector.dx < 0) {
            
        } else if (vector.dy > 0 && vector.dx < 0) {
            rawAngle *= -1
            rawAngle += M_PI_2
        }
        return CGFloat(rawAngle)
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



