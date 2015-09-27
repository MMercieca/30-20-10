//
//  Speed.swift
//  30-20-10
//
//  Created by Matthew Mercieca on 8/14/15.
//  Copyright (c) 2015 Mutually Human. All rights reserved.
//

import Foundation
import UIKit

enum Speed: Int {
    
    case Jog = 1
    case Run = 2
    case Sprint = 3
    case Break = 4
    case Warmup = 5
    
    func description() -> String {
        switch self {
        case .Jog:
            return "Jog"
        case .Run:
            return "Run"
        case .Sprint:
            return "Sprint"
        case .Break:
            return "Jog"
        case .Warmup:
            return "Warmup"
        }
    }
    
    func color() -> UIColor {
        switch self {
        case .Jog:
            return UIColor.blueColor()
        case .Run:
            return UIColor.orangeColor()
        case .Sprint:
            return UIColor.redColor()
        case .Break:
            return UIColor.blueColor()
        case .Warmup:
            return UIColor.blueColor()
        }
    }
    
    func soundUrl() -> NSURL {
        switch self {
        case .Jog,
             .Warmup,
             .Break:
            return NSBundle.mainBundle().URLForResource("a", withExtension: "mp3")!
        case .Run:
            return NSBundle.mainBundle().URLForResource("c", withExtension: "mp3")!
        case .Sprint:
            return NSBundle.mainBundle().URLForResource("a2", withExtension: "mp3")!
        }
    }
    
    func runFor() -> Double {
        switch self {
        case .Jog:
            return 30.0
        case .Run:
            return 20.0
        case .Sprint:
            return 10.0
        case .Break:
            return 120.0
        case .Warmup:
            return 300.0
        }
    }
}
