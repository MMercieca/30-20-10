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
    
    var audioPlayer = AVAudioPlayer()
    let calendar = NSCalendar.currentCalendar()
    var warmup = false
    var timer = NSTimer()
    var intervals = [Speed]()
    var total = 0.0
    var timePassed = 0.0
    var timePassedTimer = NSTimer()
    var currentColor = UIColor.blueColor()
    var updateInterval = 0.5
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient, error: nil)
        AVAudioSession.sharedInstance().setActive(true, error: nil)
    }
    
    //TODOMPM - use one timer
    //TODOMPM - add pausing
    //TODOMPM - add mid app stopping
    //TODOMPM - add setting screen (number of loops and warmup)
    //TODOMPM - add finished state
    
    @IBAction func startStopPressed(sender: UIButton) {
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
        
        timerFired()
        updateProgress()
    }
    
    func timerFired() {
        if let nextInterval = intervals.first {
            intervals.removeAtIndex(0)
            currentColor = nextInterval.color()
            speedLabel.text = nextInterval.description()
            alertSpeed(nextInterval)
            
            timer = NSTimer(timeInterval: nextInterval.runFor(), target: self, selector: "timerFired", userInfo: nil, repeats: false)
            //TODOMPM: this needs to work in background execution mode
            NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        }
    }
    
    func updateProgress() {
        timePassed += updateInterval
        progress.pushUpdate((updateInterval*100/total, currentColor))
        timePassedTimer = NSTimer(timeInterval: updateInterval, target: self, selector: "updateProgress", userInfo: nil, repeats: false)
        NSRunLoop.mainRunLoop().addTimer(timePassedTimer, forMode: NSRunLoopCommonModes)
    }
    
    func alertSpeed(currentSpeed:Speed) {
        audioPlayer = AVAudioPlayer(contentsOfURL: currentSpeed.soundUrl(), error: nil)
        audioPlayer.play()
    }
}

