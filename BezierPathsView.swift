//
//  BezierPathsView.swift
//  Bricks0
//
//  Created by Robert Lummis on 6/6/15.
//  Copyright (c) 2015 ElectricTurkeySoftware. All rights reserved.
//

import UIKit

class BezierPathsView: UIView
{
    private var bezierPaths = [String:UIBezierPath]()
    
    func setPath(path: UIBezierPath?, named name: String) {
        bezierPaths[name] = path
        setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        for (_, path) in bezierPaths {
            let c = UIGraphicsGetCurrentContext()
            let strokeColor: [CGFloat] = [0.0, 1.0, 0.0, 1.0]
            let fillColor: [CGFloat] = [1.0, 0.0, 0.0, 1.0]
            CGContextSetStrokeColor(c, strokeColor)
            CGContextSetFillColor(c, fillColor)
            path.stroke()
            path.fill()
            
        }
    }
}

