//
//  BreakoutView.swift
//  Breakout
//
//  Created by Ben Vest on 2/8/16.
//  Copyright © 2016 vreest. All rights reserved.
//

import UIKit

class BreakoutView: UIView {

    private var bezierPaths = [String: UIBezierPath]()
    
    func setPath(path: UIBezierPath?, named name: String) {
        bezierPaths[name] = path
        setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        for (_, path) in bezierPaths {
            path.stroke()
        }
    }

}
