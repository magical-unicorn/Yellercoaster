//
//  GameScene.swift
//  Yellercoaster
//
//  Created by noliv on 23/01/2015.
//  Copyright (c) 2015 magicalunicorns. All rights reserved.
//

import SpriteKit
import AVFoundation


class GameScene: SKScene {
    var avancement = 0.0
    var groundBuilt = 0.0
    var groundItemsTotalCount = 0
	var maxVelocity : CGFloat = 550.0
    var previousVelocity : CGFloat = 0.0
    var groundItems = [SKNode]()
	let patternWidth:CGFloat = 540.0
	var currentPattern:CGFloat = -1.0;
	var currentJoint:SKPhysicsJointLimit?;
	var wagons = [SKNode]()
	var wagonsNumber = 6;
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
    var bgSprite : SKSpriteNode?
	var audioPlayer: AVAudioPlayer?;

    func createWagons(container: SKNode) {
        let world = self.childNodeWithName("world")!
        let wag = world.childNodeWithName("wagon")! as SKSpriteNode
        let wag1 = world.childNodeWithName("wagon1")! as SKSpriteNode
        let wag2 = world.childNodeWithName("wagon2")! as SKSpriteNode
        let wag3 = world.childNodeWithName("wagon3")! as SKSpriteNode
        let wag4 = world.childNodeWithName("wagon4")! as SKSpriteNode
        let wag5 = world.childNodeWithName("wagon5")! as SKSpriteNode
        
        wag.color = SKColor.clearColor()
        wag1.color = SKColor.clearColor()
        wag2.color = SKColor.clearColor()
        wag3.color = SKColor.clearColor()
        wag4.color = SKColor.clearColor()
        wag5.color = SKColor.clearColor()
        
        wag.texture = SKTexture(imageNamed: "Alain")
        wag1.texture = SKTexture(imageNamed: "thiba")
        wag2.texture = SKTexture(imageNamed: "chris")
        wag3.texture = SKTexture(imageNamed: "Laurence")
        wag4.texture = SKTexture(imageNamed: "yohan")
        wag5.texture = SKTexture(imageNamed: "Oli")
    }
    
    func getWagonSprite(perso: String) -> SKSpriteNode {
        let wagon = SKSpriteNode(imageNamed: perso)
        if let dico = wagon.userData {
            dico.setObject(perso, forKey: "perso")
        } else {
            wagon.userData = NSMutableDictionary()
            wagon.userData?.setObject(perso, forKey: "perso")
        }
        let body = SKPhysicsBody(circleOfRadius: 20.0)
        body.affectedByGravity = true
        body.friction = 0.0
        body.mass = 0.0089
        
        wagon.physicsBody = body
        return wagon
    }
    
    func avantDuWagon(wagon: SKNode) -> CGPoint {
        let center = wagon.position
        return CGPoint(x: center.x, y: center.y + 0.0)
    }
    func arriereDuWagon(wagon: SKNode) -> CGPoint {
        let center = wagon.position
        return CGPoint(x: center.x, y: center.y - 0.0)
    }
	
    override func didMoveToView(view: SKView) {
		
		var song = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("II", ofType: "aifc")!)
		var error2:NSError?
		self.audioPlayer = AVAudioPlayer(contentsOfURL: song, error: &error2)
		self.audioPlayer!.numberOfLoops = -1
		self.audioPlayer!.prepareToPlay()
		self.audioPlayer!.play()
		
        let bg = SKSpriteNode(imageNamed: "background.png")
        self.bgSprite = bg
        bg.xScale = 0.5
        bg.yScale = 0.5
        bg.zPosition = -5.0
        bg.position = CGPoint(x: 0.0, y: 384.0)
        self.addChild(bg)
        
        let world = self.childNodeWithName("world")!
        
        self.createWagons(world)

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
		
		wagons.append(wagon!)
		wagons.append(wagon1!)
		wagons.append(wagon2!)
		wagons.append(wagon3!)
		wagons.append(wagon4!)
		wagons.append(wagon5!)

        
		joint1 = SKPhysicsJointSpring.jointWithBodyA(wagon!.physicsBody, bodyB: wagon1!.physicsBody, anchorA: arriereDuWagon(wagon!), anchorB: avantDuWagon(wagon1!))
		self.physicsWorld.addJoint(joint1!)
		joint2 = SKPhysicsJointSpring.jointWithBodyA(wagon1!.physicsBody, bodyB: wagon2!.physicsBody, anchorA: arriereDuWagon(wagon1!), anchorB: avantDuWagon(wagon2!))
		self.physicsWorld.addJoint(joint2!)
		joint3 = SKPhysicsJointSpring.jointWithBodyA(wagon2!.physicsBody, bodyB: wagon3!.physicsBody, anchorA: arriereDuWagon(wagon2!), anchorB: avantDuWagon(wagon3!))
		self.physicsWorld.addJoint(joint3!)
		joint4 = SKPhysicsJointSpring.jointWithBodyA(wagon3!.physicsBody, bodyB: wagon4!.physicsBody, anchorA: arriereDuWagon(wagon3!), anchorB: avantDuWagon(wagon4!))
		self.physicsWorld.addJoint(joint4!)
		joint5 = SKPhysicsJointSpring.jointWithBodyA(wagon4!.physicsBody, bodyB: wagon5!.physicsBody, anchorA: arriereDuWagon(wagon4!), anchorB: avantDuWagon(wagon5!))
		self.physicsWorld.addJoint(joint5!)

		
		
		var TimeoutWait = SKAction.waitForDuration(60.0)
		var TimeoutRun = SKAction.runBlock {
			self.findepartie("TIME IS UP!")
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
			
			// fin du jeu si tombé dans un trou
			if self.wagon!.position.y < -130.0 {
				self.findepartie("TRAIN CRASH!")
			}
			
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
		if wagonsNumber == 6 {
			self.physicsWorld.removeJoint(joint5!)
		} else if wagonsNumber == 5 {
			self.physicsWorld.removeJoint(joint4!)
		} else if wagonsNumber == 4 {
			self.physicsWorld.removeJoint(joint3!)
		} else if wagonsNumber == 3 {
			self.physicsWorld.removeJoint(joint2!)
		} else if wagonsNumber == 2 {
			self.physicsWorld.removeJoint(joint1!)
		} else {
			self.findepartie("NO MORE WAGON LEFT!")
		}
		wagonsNumber--;
	}
	
	func findepartie(s: String) {
		let app = UIApplication.sharedApplication().delegate as AppDelegate
		let world = self.childNodeWithName("world")!
		wagon = world.childNodeWithName("wagon")!

		app.distance = Int(Double(wagon!.position.x))
		app.score = app.distance*3 ;
		app.message = s;
		self.audioPlayer!.stop()
		if let scene = ScoreScene.unarchiveFromFile("ScoreScene") as? ScoreScene {
			self.view?.presentScene(scene, transition: SKTransition.flipVerticalWithDuration(0.6))
		} else {
			println("bug")
			
		}
		println("fin de partie: " + s)
	}
	
    func buildGroundIfNeeded() {

        let world = self.childNodeWithName("world")!
        if let ground = world.childNodeWithName("ground") {
            if (self.groundBuilt - self.avancement - 1100.0 <= 0.0) {
                groundItemsTotalCount++
                let bHeight = 15 + arc4random() % 500
                var bezier = self.getBezier(Double(patternWidth),ySize: Double(bHeight))
                if (((groundItemsTotalCount-1) % 7) == 0) {
                    bezier = self.getBezierTrou(Double(patternWidth),ySize: Double(350))
                }
                let shape = SKShapeNode(path: bezier.CGPath)
                shape.fillColor = SKColor.whiteColor()
                //let texture = SKTexture(imageNamed: "alpha.png")!
                //shape.fillTexture = texture
                shape.setTiledFillTexture("roller_pattern", tileSize: CGSize(width: 62.4, height: 82.2))
                //shape.strokeColor = SKColor(red: 202.0, green: 158.0, blue: 103.0, alpha: 255.0)
                shape.strokeColor = SKColor.brownColor()
                shape.lineWidth = 2.0
                shape.position = CGPoint(x: self.groundBuilt, y: 0.0)
				
                shape.xScale = 1.0
                shape.yScale = 1.0
                let body = SKPhysicsBody(polygonFromPath: bezier.CGPath)
                body.affectedByGravity = false
                body.dynamic = false
                shape.physicsBody = body
                
                ground.addChild(shape)
//                
//                let squareBezier = self.getSquareBezier(Double(patternWidth))
//                let shape2 = SKShapeNode(path: squareBezier.CGPath)
//                shape2.fillColor = SKColor.whiteColor()
//                shape2.setTiledFillTexture("roller_pattern", tileSize: CGSize(width: 62.4, height: 82.2))
//                shape2.strokeColor = SKColor.blackColor()
//                shape2.position = CGPoint(x: self.groundBuilt, y: 0.0)
//				
//                shape.addChild(shape2)
                
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
        
        let xDiff = CGFloat(35.0*level)
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
        
        var count = 0
        for voiture in wagons {
            count++
            if (voiture.name != "wagon" && count == self.wagonsNumber) {
                self.centripeteTaMere(voiture)
            }
        }
        
        gardeLesDansLordre()
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
            
            wagonnet.physicsBody?.applyForce(CGVector(dx: ortho.dx * 1.2, dy: ortho.dy * 1.2))
        }
    }
    
    override func didFinishUpdate() {
        self.bgSprite!.position = CGPoint(x: Double(self.bgSprite!.size.width * 0.5) - avancement * 0.05, y: 384.0)
        
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
        let filteredVelocity = 0.07 * velocity + 0.93 * prevVelo
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
        if (velocity > 5.2) {
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
        path.addLineToPoint(CGPoint(x: 0.0, y: -400.0))
        path.addLineToPoint(CGPoint(x: patternWidth, y: -400.0))
        return path
    }
    
    func getSquareBezier(xSize: Double) -> UIBezierPath {
        let path = UIBezierPath()
        let factor = xSize / 400.0
        path.moveToPoint(CGPoint(x: patternWidth, y: 0.0))
        path.addLineToPoint(CGPoint(x: 0.0, y: 0.0))
        path.addLineToPoint(CGPoint(x: 0.0, y: -400.0))
        path.addLineToPoint(CGPoint(x: patternWidth, y: -400.0))
        return path
    }
    
    func getBezierTrou(xSize: Double, ySize: Double) -> UIBezierPath {
        let path = UIBezierPath()
        let factor = xSize / 400.0
        let betterY = CGFloat(175.0 + ySize * 0.15)
        path.moveToPoint(CGPoint(x: patternWidth, y: 0.0))
        path.addLineToPoint(CGPoint(x: patternWidth, y: -400.0))
        path.addLineToPoint(CGPoint(x: 0.5 * patternWidth, y: -400.0))
        path.addLineToPoint(CGPoint(x: 0.5 * patternWidth, y: 0.0))
        path.addLineToPoint(CGPoint(x: 0.5 * patternWidth, y: 0.75 * betterY))
        path.addCurveToPoint(CGPoint(x: 0.35 * patternWidth, y: betterY), controlPoint1: CGPoint(x: 0.5 * patternWidth, y: 0.95 * betterY), controlPoint2: CGPoint(x: 0.46 * patternWidth, y: betterY))
        
        path.addCurveToPoint(CGPoint(x: 0.0, y: 0.0), controlPoint1: CGPoint(x: 0.20 * patternWidth, y: betterY), controlPoint2: CGPoint(x: 0.17 * patternWidth, y: 0.0))
        
        path.addLineToPoint(CGPoint(x: 0.0, y: -400.0))
    
        path.addLineToPoint(CGPoint(x: patternWidth, y: -400.0))
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
        var leNode : SKNode?
        if (prevNode != nil) {
            leNode = prevNode
        } else {
            leNode = nxtNode
        }
		let shape = leNode as SKShapeNode;
		
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
            if (CGFloat(c[1]) >= 0.0) {
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
    
    func gardeLesDansLordre() {
        let world = self.childNodeWithName("world")!
        let wagonPrincipal = world.childNodeWithName("wagon")!
        var previousX = wagonPrincipal.position.x
        var previousWagon = wagonPrincipal
        for wagon in self.wagons {
            if (wagon.position.x > previousX) {
                if let bodyPrev = previousWagon.physicsBody {
                    bodyPrev.applyImpulse(CGVector(dx: 10.0, dy: 0.0))
                }
                if let bodyCourant = wagon.physicsBody {
                    bodyCourant.applyImpulse(CGVector(dx: -10.0, dy: 0.0))
                }
            }
            previousX = wagon.position.x
            previousWagon = wagon
        }
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



