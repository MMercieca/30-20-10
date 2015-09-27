//
//  ViewController.swift
//  30-20-10
//
//  Created by Matthew Mercieca on 8/14/15.
//  Copyright (c) 2015 Mutually Human. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var progress: CircleProgress!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    var audioPlayer = AVAudioPlayer()
    let calendar = NSCalendar.currentCalendar()
    var warmup = false
    var timer = NSTimer()
    var intervals = [Speed]()
    var total = 0.0
    var timePassed = 0.0
    var currentColor = UIColor.blueColor()
    var updateInterval = 0.5
    var currentIntervalProgress = 0.0
    var mode = Mode.Stopped
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }
        
        timer = NSTimer(timeInterval: updateInterval, target: self, selector: "timerFired", userInfo: nil, repeats: true)
        
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        
        // Can't do background execution mode.  So we just won't sleep.
        UIApplication.sharedApplication().idleTimerDisabled = true;
    }
    
    //TODOMPM - Add background execution mode - it doesn't look like this app meets the criteria for background 
    //          execution mode.  
    //          See: https://developer.apple.com/library/ios/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/BackgroundExecution/BackgroundExecution.html
    //          I might be able to hack around it, but I'll put that on the back burner for now.
    //          Of course, if I deliberately hack around it the app may just get rejected from the app store.
    //TODOMPM - add interruption - App can't run in background so this likely isn't necessary
    //TODOMPM - add setting screen (number of loops and warmup)
    //TODOMPM - test finished state
    
    
    @IBAction func startPressed(sender: UIButton) {
        mode = Mode.Running
        resumeButton.hidden = true
        startRunning()
    }
    
    @IBAction func pausePressed(sender: UIButton) {
        mode = Mode.Paused
        pauseButton.hidden = true
        resumeButton.hidden = false
        stopButton.hidden = false
    }
    
    @IBAction func resumePressed(sender: UIButton) {
        mode = Mode.Running
        resumeButton.hidden = true
        stopButton.hidden = true
        pauseButton.hidden = false
    }
    
    @IBAction func stopPressed(sender: UIButton) {
        mode = Mode.Stopped
        resumeButton.hidden = true
        stopButton.hidden = true
        pauseButton.hidden = true
        startStopButton.hidden = false
        speedLabel.text = ""
        reset()
    }

    func startRunning() {
        progress.clear()
        if (self.warmup) {
            intervals.append(Speed.Warmup)
        }
        
        for _ in 1...3 {
            for _ in 1...5
            {
                intervals.append(Speed.Jog)
                intervals.append(Speed.Run)
                intervals.append(Speed.Sprint)
            }
            intervals.append(Speed.Break)
        }

        total = intervals.reduce(0, combine: { $0 + $1.runFor() }) + updateInterval
        
        startStopButton.hidden = true
        pauseButton.hidden = false;
    }
    
    func reset() {
        currentIntervalProgress = 0.0
        intervals.removeAll(keepCapacity: false)
        mode = Mode.Stopped
    }
    
    func finish() {
        speedLabel.text = "Finished"
        alertSpeed(Speed.Jog)
        alertSpeed(Speed.Run)
        alertSpeed(Speed.Sprint)
        pauseButton.hidden = true;
        startStopButton.hidden = false;
        reset();
    }
    
    func timerFired() {
        if (mode == Mode.Running) {
            updateIntervals()
            updateProgress()
        }
    }
    
    func updateIntervals() {
        if (intervals.count == 0) {
            return;
        }
        
        let currentInterval = intervals.first!
        
        if currentIntervalProgress == 0.0 {
            currentColor = currentInterval.color()
            speedLabel.text = currentInterval.description()
            alertSpeed(currentInterval)
            currentIntervalProgress += updateInterval
        } else if currentIntervalProgress > currentInterval.runFor() {
            currentIntervalProgress = 0.0
            intervals.removeAtIndex(0)
        } else {
            currentIntervalProgress += updateInterval
        }
    }
    
    func updateProgress() {
        if mode == Mode.Running {
            if let _ = intervals.first {
                let percent = updateInterval / total * 100
                progress.pushUpdate(( percent, currentColor))
            } else {
                finish()
            }
        }
    }
    
    func alertSpeed(currentSpeed:Speed) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: currentSpeed.soundUrl())
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch {
            //Humm.  An empty catch.  Except what would I do here anyway?
        }
    }
}

