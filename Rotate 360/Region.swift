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
    var maxY: CGFloat = 0.0           // for x, y coordinates to include conneted screens
    
    var width: CGFloat { maxX - minX }
    var height: CGFloat { maxY - minY }
    
    func setProperties(screen: NSScreen) {
        minX = min(screen.frame.minX, minX)
        maxX = max(screen.frame.maxX, maxX)
        minY = min(screen.frame.minY, minY)
        maxY = max(screen.frame.maxY, maxY)
    }
}
