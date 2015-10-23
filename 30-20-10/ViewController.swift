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
    var warmup = false
    var timer = NSTimer()
    var intervals = [Speed]()
    var totalToRun = 0.0
    var nextAlarmTime = 0.0
    var ellapsedTime = 0.0
    var currentColor = Speed.Warmup.color()
    var updateInterval = 0.5
    var mode = Mode.Stopped
    var lastUpdate = NSDate()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        
        mode = Mode.Stopped
        
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
        
        // Not sleeping because background execution likely requires some hacking
        UIApplication.sharedApplication().idleTimerDisabled = true;
        
        // Sometimes runners get phone calls at inconvenient times
        // TODOMPM - This is where nifty code would go to get the alerting to work when the app is in the
        //           background.  It doesn't look like this app meets the criteria for background
        //           execution mode.
        //           See: https://developer.apple.com/library/ios/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/BackgroundExecution/BackgroundExecution.html
        //           I might be able to hack around it, but I'll put that on the back burner for now.
        //           Of course, if I deliberately hack around it the app may just get rejected from the
        //           store.
        // TODOMPM - After trying to hack around the above, make sure interruption works correctly.
    }
    
    //TODOMOM - Add settings screen
    
    @IBAction func startPressed(sender: UIButton) {
        mode = Mode.Running
        lastUpdate = NSDate()
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
        lastUpdate = NSDate()
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
        intervals.append(Speed.Finished)

        totalToRun = intervals.reduce(0, combine: { $0 + $1.runFor() })
        startStopButton.hidden = true
        pauseButton.hidden = false;
        alert()
    }
    
    func alert() {
        if let currentInterval = intervals.first {
            currentColor = currentInterval.color()
            speedLabel.text = currentInterval.description()
            alertSpeed(currentInterval)
            nextAlarmTime += currentInterval.runFor()
            intervals.removeAtIndex(0)
        }
    }
    
    func reset() {
        nextAlarmTime = 0.0
        intervals.removeAll(keepCapacity: false)
        mode = Mode.Stopped
    }
    
    func finish() {
        pauseButton.hidden = true;
        startStopButton.hidden = false;
    }
    
    func timerFired() {
        if (mode == Mode.Running) {
            updateIntervals()
        }
    }
    
    func updateIntervals() {
        let now = NSDate()
        let thisSlice = now.timeIntervalSinceDate(lastUpdate)
        updateProgress(thisSlice)
        ellapsedTime += thisSlice
        
        if ellapsedTime >= nextAlarmTime {
            alert()
        }
        
        lastUpdate = now
    }
    
    func updateProgress(elapsed:NSTimeInterval) {
        if mode == Mode.Running {
            if let _ = intervals.first {
                let percent = elapsed / totalToRun * 100
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

