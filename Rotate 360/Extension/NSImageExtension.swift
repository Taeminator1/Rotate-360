//
//  NSImageExtension.swift
//  Rotate 360
//
//  Created by 윤태민 on 6/17/21.
//  Copyright © 2021 Taemin Yun. All rights reserved.
//

import Cocoa

extension NSImage {
    static func swatchWithColor(color: NSColor, size: NSSize) -> NSImage {
        let image = NSImage(size: size)
        
        image.lockFocus()
        color.drawSwatch(in: NSMakeRect(0, 0, size.width, size.height))
        image.unlockFocus()
        
        return image
    }
}
