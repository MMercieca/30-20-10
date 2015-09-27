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
        
        //TODOMPM: this will likely need to be updated for background execution mode
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    }
    
    //TODOMPM - add interruption
    //TODOMPM - add setting screen (number of loops and warmup)
    //TODOMPM - test finished state
    //TODOMPM - Add background execution mode
    
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
        
        total = intervals.reduce(0, combine: { $0 + $1.runFor() })
        
        startStopButton.hidden = true
        pauseButton.hidden = false;
    }
    
    func reset() {
        currentIntervalProgress = 0.0
        intervals.removeAll(keepCapacity: false)
        progress.clear()
        mode = Mode.Stopped
    }
    
    func finish() {
        speedLabel.text = "Finished"
        alertSpeed(Speed.Jog)
        alertSpeed(Speed.Run)
        alertSpeed(Speed.Sprint)
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
            if let currentInterval = intervals.first {
                timePassed += updateInterval
                let percent = currentIntervalProgress / currentInterval.runFor() / total * 100
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

