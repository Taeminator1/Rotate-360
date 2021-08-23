//
//  NSPointExtension.swift
//  Rotate 360
//
//  Created by 윤태민 on 6/20/21.
//  Copyright © 2021 Taemin Yun. All rights reserved.
//

import Cocoa

extension NSPoint {
    // Return to if mouse cursor is in the screen or not.
    func isInTheScreen(_ screen: NSScreen) -> Bool {
        return self.x >= screen.frame.minX && self.x <= screen.frame.maxX && self.y >= screen.frame.minY && self.y <= screen.frame.maxY
    }
}
