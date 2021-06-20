//
//  Region.swift
//  Rotate 360
//
//  Created by 윤태민 on 6/17/21.
//  Copyright © 2021 Taemin Yun. All rights reserved.
//

import Cocoa

class Region {
    var minX: CGFloat = 0.0
    var maxX: CGFloat = 0.0
    var minY: CGFloat = 0.0
    var maxY: CGFloat = 0.0             // for x, y coordinates to include conneted screens
    
    var width: CGFloat = 0              // Consider when screens are stacked vertically or horizontally
    var height: CGFloat = 0
    
    func setProperties(screen: NSScreen) {
        minX = min(screen.frame.minX, minX)
        maxX = max(screen.frame.maxX, maxX)
        minY = min(screen.frame.minY, minY)
        maxY = max(screen.frame.maxY, maxY)
        
        width += screen.frame.maxX - screen.frame.minX
        height += screen.frame.maxY - screen.frame.minY
    }
}
