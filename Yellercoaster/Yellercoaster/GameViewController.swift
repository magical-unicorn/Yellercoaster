//
//  GameViewController.swift
//  Yellercoaster
//
//  Created by noliv on 23/01/2015.
//  Copyright (c) 2015 magicalunicorns. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

// Extension de SKNode pour permettre d'obtenir un objet SKNode à partir des fichiers .sks
extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as SKScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController, AVAudioRecorderDelegate {

    var recorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    var lowPassResults:Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialisation de l'enregistreur pour détecter le volume sonore du microphone plus tard
        let url = NSURL(fileURLWithPath: "/dev/null")
        let settings = [AVSampleRateKey: 44100.0,
                        AVFormatIDKey: kAudioFormatAppleLossless,
                        AVNumberOfChannelsKey: 1,
                        AVEncoderAudioQualityKey: AVAudioQuality.Max.rawValue]
        
        let audioSession = AVAudioSession.sharedInstance()
        var err: NSError?
        audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        if let e1 = err {
            println(e1.localizedDescription)
        }
        
        var error: NSError?
        self.recorder = AVAudioRecorder(URL: url, settings: settings, error: &error)
        if let e = error {
            println(e.localizedDescription)
        } else {
            let rec = self.recorder!
            rec.delegate = self
            rec.meteringEnabled = true
            rec.prepareToRecord() // creates/overwrites the file at soundFileURL
            rec.record()
            let levelTimer = NSTimer.scheduledTimerWithTimeInterval(0.03, target: self, selector: "level", userInfo: nil, repeats: true)
        }
        
        // Test de jouage musical pour vérifier que ça fonctionne en même temps que l'enregistrement (ok ça marche, je laisse le code pour le moment où on integrera la zique pour de bon)
        //var song = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("livingdead", ofType: "mp3")!)
        //var error2:NSError?
        //self.audioPlayer = AVAudioPlayer(contentsOfURL: song, error: &error2)
        //self.audioPlayer?.prepareToPlay()
        //self.audioPlayer?.play()
        
        if let scene = SplashScene.unarchiveFromFile("SplashScene") as? SplashScene {
            // Configure the view.
            let skView = self.view as SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.showsPhysics = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene, transition: SKTransition.flipVerticalWithDuration(0.6))
            
        }
    }
    
    // Ces trois fonctions obtiennent le volume sonore du microphone et filtrent ce dernier pour obtenir un truc exploitable entre 0 et 1 que l'on stocke dans l'AppDelegate pour qu'il soit accessible de n'importe où, et ouais mec.
    func sinusite(x: Double) -> Double {
        return sin(x*M_PI/2.0)
    }
    func megasinusite(x: Double) -> Double {
        return sinusite(sinusite(sinusite(x)))
    }
    func level() {
        self.recorder?.updateMeters()
        let ALPHA = 0.09
        let averagePowerForChannel = self.megasinusite(M_PI * pow(10, ALPHA * Double(self.recorder!.averagePowerForChannel(0))))
        self.lowPassResults = ALPHA * averagePowerForChannel + (1.0 - ALPHA) * self.lowPassResults
        // NSLog("Average input: %f Peak input: %f Low pass results: %f", self.recorder!.averagePowerForChannel(0), self.recorder!.peakPowerForChannel(0), lowPassResults)
        let app = UIApplication.sharedApplication().delegate as AppDelegate
        app.audioLevel = self.lowPassResults
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    // La, c'est juste pour dire que l'app ne fonctionne qu'en mode paysage.
    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.Landscape.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.Landscape.rawValue)
        }
    }

    // Ça on s'en tape
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
