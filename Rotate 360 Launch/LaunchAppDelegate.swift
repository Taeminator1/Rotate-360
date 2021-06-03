//
//  AppDelegate.swift
//  Rotate 360 Launch
//
//  Created by 윤태민 on 6/17/20.
//  Copyright © 2020 Taemin Yun. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = runningApps.contains {
            $0.bundleIdentifier == "com.Taeminator.Rotate-360"
        }
            
        if !isRunning {
            var path = Bundle.main.bundlePath as NSString
            for _ in 1...4 {
                path = path.deletingLastPathComponent as NSString
            }
            NSWorkspace.shared.launchApplication(path as String)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

