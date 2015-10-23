//
//  CircleProgress.swift
//  CircleProgress
//
//  Created by Matthew Mercieca on 8/21/15.
//  Copyright (c) 2015 Mutually Human. All rights reserved.
//

import UIKit

class CircleProgress: UIView {
    
    var lineWidth: CGFloat = 15 { didSet { setNeedsDisplay() } }
    var outlineWidth: CGFloat = 5 { didSet { setNeedsDisplay() } }
    var canGoOver100Percent: Bool = false
    
    var outlineColor: UIColor = UIColor.grayColor() { didSet { setNeedsDisplay() } }
    
    var segments = [(Double, UIColor)]()
    var currentColor = UIColor.grayColor()
    
    var progressCenter: CGPoint {
        return convertPoint(center, fromView: superview);
    }
    
    var progressRadius: CGFloat {
        return min(bounds.size.width - (lineWidth * 2), bounds.size.height - (lineWidth * 2)) / 2
    }
    
    func updateLast(newValue: (Double, UIColor)) {
        if segments.count > 0 {
            segments[segments.count - 1] = newValue
        }
        else {
            segments.append(newValue)
        }
        setNeedsDisplay()
    }
    
    func pushUpdate(newValue: (Double, UIColor)) {
        if segments.count == 0 {
            currentColor = newValue.1
            segments.append(newValue)
            return;
        }
        
        if (newValue.1 == currentColor) {
            let current = segments[(segments.count-1)]
            segments[(segments.count - 1)] = (current.0 + newValue.0, currentColor)
        } else {
            segments.append(newValue)
            currentColor = newValue.1
        }
        
        setNeedsDisplay()
    }
    
    func clear() {
        segments.removeAll(keepCapacity: false)
        setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        var startAngle = CGFloat(M_PI * -0.5)
        
        drawSegment(startAngle, endAngle: CGFloat(2*M_PI - M_PI * 0.5), lineColor: outlineColor, width: lineWidth)

        for segment in self.segments {
            let endAngle = CGFloat(2 * M_PI * segment.0 / 100) + startAngle
            
            drawSegment(startAngle, endAngle: endAngle, lineColor: segment.1.colorWithAlphaComponent(0.5), width: lineWidth)
            drawSegment(startAngle, endAngle: endAngle, lineColor: segment.1, width: lineWidth - outlineWidth)
            
            startAngle = endAngle
        }
        
    }
    
    func drawSegment(startAngle: CGFloat, endAngle: CGFloat, lineColor: UIColor, width: CGFloat) {
        let path = UIBezierPath(arcCenter: progressCenter, radius: progressRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        lineColor.setStroke()
        path.lineWidth = width
        path.stroke()
    }

}
