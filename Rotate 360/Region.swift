//
//  Region.swift
//  Rotate 360
//
//  Created by 윤태민 on 6/17/21.
//  Copyright © 2021 Taemin Yun. All rights reserved.
//

//  Region for Screen in X-Y Coordinator

import Cocoa

class Region {
    private(set) var minX: CGFloat = 0.0
    private(set) var maxX: CGFloat = 0.0
    private(set) var minY: CGFloat = 0.0
    private(set) var maxY: CGFloat = 0.0        // For x, y coordinates to include conneted screens
    
    private(set) var width: CGFloat = 0
    private(set) var height: CGFloat = 0        // Consider when screens are stacked vertically or horizontally.
    
    var gapX: CGFloat { maxX - minX }
    var gapY: CGFloat { maxY - minY }
    
    // Renew the properties according to screen.
    func setProperties(screen: NSScreen) {
        minX = min(screen.frame.minX, minX)
        maxX = max(screen.frame.maxX, maxX)
        minY = min(screen.frame.minY, minY)
        maxY = max(screen.frame.maxY, maxY)
        
        width += screen.frame.maxX - screen.frame.minX
        height += screen.frame.maxY - screen.frame.minY
    }
}
