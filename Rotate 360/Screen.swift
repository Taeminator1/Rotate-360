//
//  Screen.swift
//  Rotate 360
//
//  Created by 윤태민 on 6/16/20.
//  Copyright © 2020 Taemin Yun. All rights reserved.
//

//  Represent screen connected with computer.
//  This Struct has static properties and methods to access anywhere in the other class.

import Foundation

enum Orientaion: Int {
    case CW = 0         // Clockwise
    case CCW = 1        // Counter Clockwise
}

struct Screen {
    static var displayPhase: Int = 0
    static var targetDisplay: CGDirectDisplayID = 0
    static var options: IOOptionBits = 0
    
    static func rotateByOrientaion(targetDisplayUnit: Int, _ Orientation: Orientaion) {
        targetDisplay = nonInternalID(UInt32(targetDisplayUnit))

        if Orientation == .CW {
            displayPhase = Int(CGDisplayRotation(targetDisplay))
            options = angle2options(displayPhase == 0 ? 270 : displayPhase - 90)
        }
        else if Orientation == .CCW {
            displayPhase = Int(CGDisplayRotation(targetDisplay))
            options = angle2options(displayPhase == 270 ? 0 : displayPhase + 90)
        }
        let displayID: CGDirectDisplayID = cgIDfromU32(targetDisplay)
        let service: io_service_t = duplicatedCGDisplayIOServicePort(displayID)

        IOServiceRequestProbe(service, options)
    }
}
