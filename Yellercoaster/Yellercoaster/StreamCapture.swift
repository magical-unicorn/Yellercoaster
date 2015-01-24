//
//  StreamCapture.swift
//  Yellercoaster
//
//  Created by Biou on 24/01/2015.
//  Copyright (c) 2015 magicalunicorns. All rights reserved.
//

import Foundation
import AVFoundation

// singleton de sa maman
private let _StreamCaptureSharedInstance = StreamCapture()

class StreamCapture: NSObject, AVAudioRecorderDelegate {
	var recorder: AVAudioRecorder?
	var audioPlayer: AVAudioPlayer?
	var lowPassResults:Double = 0.0
	
	class var sharedInstance: StreamCapture {
		return _StreamCaptureSharedInstance
	}
	
	func setup() {

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
		
		
	}
	
	func pause() {
		self.recorder!.pause()
	}
	
	func stop() {
		self.recorder!.stop()
	}
	
	func resume() {
		self.recorder!.record()
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
	
}