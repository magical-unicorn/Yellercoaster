//
//  GameScene.swift
//  Yellercoaster
//
//  Created by noliv on 23/01/2015.
//  Copyright (c) 2015 magicalunicorns. All rights reserved.
//

import SpriteKit
import AVFoundation
import MobileCoreServices

class SplashScene: SKScene {

    let captureSession = AVCaptureSession()
    var captureDevice : AVCaptureDevice?
    var stillImageOutput = AVCaptureStillImageOutput()
    var imageData: NSData!
    var shotImage: UIImage!
    var cameratype: Bool = true
    var shotPicture: UIImage!
	var audioPlayer: AVAudioPlayer?;

    override func didMoveToView(view: SKView) {
        var moveRight = SKAction.moveByX(590, y: 0, duration: 40.0)
        var moveLeft = SKAction.moveByX(-590, y: 0, duration: 40.0)
        var sequence = SKAction.sequence([moveLeft,moveRight])
        var animation = SKAction.repeatActionForever(sequence)
        var bg = self.childNodeWithName("background")!
        bg.runAction(animation)
		var song = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("intro", ofType: "aifc")!)
		var error2:NSError?
		self.audioPlayer = AVAudioPlayer(contentsOfURL: song, error: &error2)
		self.audioPlayer!.numberOfLoops = -1
		self.audioPlayer!.prepareToPlay()
		self.audioPlayer!.play()
		
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let nodes = self.nodesAtPoint(location)
            
            for node in nodes as [SKNode] {
                println(node.name)
                if (node.name == "startBtn"){
                    self.letsPlayBaby()
                }else if (node.name == "photoBtn"){
                    self.letsMakeASelfie()
                }else if (node.name == "creditBtn"){
                    self.areWeHumans()
                }
            }
        }
    }
    
    func letsPlayBaby() {
		self.audioPlayer!.stop()
        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            self.view?.presentScene(scene, transition: SKTransition.flipVerticalWithDuration(0.6))
        }

    }
    
    func areWeHumans() {
        if let scene = CreditScene.unarchiveFromFile("CreditScene") as? CreditScene {
            self.view?.presentScene(scene, transition: SKTransition.flipVerticalWithDuration(0.6))
        }

    }

    func letsMakeASelfie() {
        println("but first, let me tage a selfie")
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        let devices = AVCaptureDevice.devices()
        for device in devices {
            if (device.hasMediaType(AVMediaTypeVideo)) {
                if(device.position == AVCaptureDevicePosition.Front) {
                    captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        beginSession()
                        takePicture()
                    }
                }
            }
        }
    }

    func takePicture() {
        stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.addOutput(stillImageOutput)
        }
        var videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)
        if(cameratype == true) {
            videoConnection.videoMirrored = false
        } else {
            videoConnection.videoMirrored = true
        }
        if videoConnection != nil {
            stillImageOutput.captureStillImageAsynchronouslyFromConnection(stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)){
                (imageDataSampleBuffer, error) -> Void in
                    self.shotPicture = UIImage(data: AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer))
                UIImageWriteToSavedPhotosAlbum(self.shotImage,self,Selector("image:didFinishSavingWithError:contextInfo:"),nil)
            }
        }
        endSession()
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo: UnsafePointer<()>) {
        dispatch_async(dispatch_get_main_queue(), {
            UIAlertView(title: "Success", message: "This image has been saved to your Camera Roll successfully", delegate: nil, cancelButtonTitle: "Close").show()
        })
    }
    
    func beginSession() {
        StreamCapture.sharedInstance.pause()
        var err : NSError? = nil
        captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &err))
        if err != nil {
            println("error: \(err?.localizedDescription)")
        }
        captureSession.startRunning()
    }
    func endSession() {
        captureSession.stopRunning()
        StreamCapture.sharedInstance.resume()
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
