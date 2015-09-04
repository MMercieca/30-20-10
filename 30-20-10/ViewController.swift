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
    var running = false;
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient, error: nil)
        AVAudioSession.sharedInstance().setActive(true, error: nil)
        
        timer = NSTimer(timeInterval: updateInterval, target: self, selector: "timerFired", userInfo: nil, repeats: true)
        
        //TODOMPM: this needs to work in background execution mode
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    }
    
    //TODOMPM - add pausing
    //TODOMPM - add mid app stopping
    //TODOMPM - add setting screen (number of loops and warmup)
    //TODOMPM - add finished state
    
    @IBAction func startStopPressed(sender: UIButton) {
        if (!running) {
            startRunning()
        } else {
            stopRunning();
        }
    }
    
    func startRunning() {
        if (self.warmup) {
            intervals.append(Speed.Warmup)
        }
        
        for i in 1...3 {
            for i in 1...5
            {
                intervals.append(Speed.Jog)
                intervals.append(Speed.Run)
                intervals.append(Speed.Sprint)
            }
            intervals.append(Speed.Break)
        }
        
        total = intervals.reduce(0, combine: { $0 + $1.runFor() })
        
        startStopButton.setTitle("Stop", forState: UIControlState.Normal)
        running = true
    }
    
    func stopRunning() {
        startStopButton.setTitle("Start", forState: UIControlState.Normal)
        running = false
        currentIntervalProgress = 0.0
        intervals.removeAll(keepCapacity: false)
        speedLabel.text = "Stopped";
    }
    
    func timerFired() {
        if (running) {
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
        if running {
            if let currentInterval = intervals.first {
                timePassed += updateInterval
                let percent = currentIntervalProgress / currentInterval.runFor() / total * 100
                progress.pushUpdate(( percent, currentColor))
            }
        }
    }
    
    func alertSpeed(currentSpeed:Speed) {
        audioPlayer = AVAudioPlayer(contentsOfURL: currentSpeed.soundUrl(), error: nil)
        audioPlayer.play()
    }
}

