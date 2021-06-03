//
//  RotateScreen.swift
//  Rotate 360
//
//  Created by 윤태민 on 6/16/20.
//  Copyright © 2020 Taemin Yun. All rights reserved.
//

import Foundation

class RotateScreen {
    
    static var currentRotation: Int = 0
    static var service: io_service_t = 0
    static var dErr: CGDisplayErr = CGDisplayErr(rawValue: 0)!
    static var targetDisplay: CGDirectDisplayID = 0
    static var options: IOOptionBits = 0
    
    static func personalRotateToSpecificAngle(targetDisplayUnit: Int, angle: Int) {
        currentRotation = Int(CGDisplayRotation(targetDisplay))
        print("Last State: \(currentRotation)º")
        
        targetDisplay = InternalID()
        if CGDisplayUnitNumber(targetDisplay) == targetDisplayUnit {
            options = angle2options(angle)

            let td2: CGDirectDisplayID = cgIDfromU32(targetDisplay)
            service = duplicatedCGDisplayIOServicePort(td2)

            IOServiceRequestProbe(service, options)
        }
        
        targetDisplay = nonInternalID(UInt32(targetDisplayUnit))
        if CGDisplayUnitNumber(targetDisplay) == targetDisplayUnit {
            options = angle2options(angle)

            let td2: CGDirectDisplayID = cgIDfromU32(targetDisplay)
            service = duplicatedCGDisplayIOServicePort(td2)

            IOServiceRequestProbe(service, options)
        }
    }

    static func personalRotateToSpecificOrientation(targetDisplayUnit: Int, Orientation: Int) {
        // Orientation = 1 -> CW
        // Orientation = 2 -> CWW
        targetDisplay = nonInternalID(UInt32(targetDisplayUnit))
        
//        print(targetDisplay)
//        print(CGDisplayUnitNumber(targetDisplay))
//        print(targetDisplayUnit)
        
        if Orientation == 1 {
            currentRotation = Int(CGDisplayRotation(targetDisplay))
//            print("Last State: \(currentRotation)º")

            switch(currentRotation) {
            case 0:
                options = angle2options(270)
            case 90:
                options = angle2options(0);
            case 180:
                options = angle2options(90);
            case 270:
                options = angle2options(180);
            default:
                break;
            }
        }
        else if Orientation == 2 {
            currentRotation = Int(CGDisplayRotation(targetDisplay))
//            print("Last State: \(currentRotation)º")

            switch(currentRotation) {
            case 0:
                options = angle2options(90)
            case 90:
                options = angle2options(180);
            case 180:
                options = angle2options(270);
            case 270:
                options = angle2options(0);
            default:
                break;
            }
        }
        let td2: CGDirectDisplayID = cgIDfromU32(targetDisplay)
        service = duplicatedCGDisplayIOServicePort(td2)

        IOServiceRequestProbe(service, options)
    }
}
