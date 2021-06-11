//
//  RotateScreen.swift
//  Rotate 360
//
//  Created by 윤태민 on 6/16/20.
//  Copyright © 2020 Taemin Yun. All rights reserved.
//

import Foundation

class Screen {
    static var displayPhase: Int = 0
    static var targetDisplay: CGDirectDisplayID = 0
    static var options: IOOptionBits = 0
    
    static func rotateToSpecificOrientation(targetDisplayUnit: Int, Orientation: Int) {
        targetDisplay = nonInternalID(UInt32(targetDisplayUnit))

//        print("Screen Phase: \(screenPhase)º")
        if Orientation == 1 {           // CW
            displayPhase = Int(CGDisplayRotation(targetDisplay))
            options = angle2options(displayPhase == 0 ? 270 : displayPhase - 90)
        }
        else if Orientation == 2 {      // CCW
            displayPhase = Int(CGDisplayRotation(targetDisplay))
            options = angle2options(displayPhase == 270 ? 0 : displayPhase + 90)
        }
        let td2: CGDirectDisplayID = cgIDfromU32(targetDisplay)
        let service: io_service_t = duplicatedCGDisplayIOServicePort(td2)

        IOServiceRequestProbe(service, options)
    }
}
