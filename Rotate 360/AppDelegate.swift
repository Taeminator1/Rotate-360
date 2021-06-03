//
//  AppDelegate.swift
//  Rotate 360
//
//  Created by 윤태민 on 6/16/20.
//  Copyright © 2020 Taemin Yun. All rights reserved.
//

import Cocoa
import ServiceManagement

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    let helperBundleName = "com.Taeminator.Rotate-360-Launch"           // for Opeing at Login
    var foundHelper: Bool = true                                        // for Opeing at Login
    
    @IBOutlet weak var openAtLoginMenuItem: NSMenuItem!
    
    static var internalDisplayOrder: Int!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
//        print("applicationDidFinishLauncing in AppDelegate")
        
        if let button = statusItem.button {
            if let icon = NSImage(named: "menubar_icon") {
                icon.isTemplate = true
                button.image = icon
            }
            button.action = #selector(self.statusBarButtonClicked(sender:))
            button.sendAction(on: [NSEvent.EventTypeMask.leftMouseUp, NSEvent.EventTypeMask.rightMouseUp])
        }
        
        // Open at Login
        foundHelper = NSWorkspace.shared.runningApplications.contains {
            $0.bundleIdentifier == helperBundleName
        }
        openAtLoginMenuItem.state = foundHelper ? .on : .off
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBOutlet weak var menu: NSMenu!
    @IBOutlet weak var customView: CustomView!
    
    var menuItem: NSMenuItem!
    
    @objc func statusBarButtonClicked(sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!

        if event.type == NSEvent.EventType.leftMouseUp {
//            print("leftMouseUp in statusBarButtonClicked")
            
            AppDelegate.internalDisplayOrder = Int(findInternalDisplay())
            customView.drawKey = false          // to excute draw function in CustomView Class
            
            menuItem = menu.item(withTitle: "CustomView")       // there is no space between Custom and View
            menuItem.view = customView!
            
            statusItem.menu = menu
            statusItem.button?.performClick(nil)
            
            statusItem.menu = nil
            
            CustomView.selectedScreen = -1
            
//            print(AppDelegate.internalDisplayOrder!)
//            print(infoDisplays())
        } else {
//            print("rightMouseUp in statusBarButtonClicked")
        }
    }
    
    @IBAction func rotateScreenClockwiseClicked(_ sender: Any) {
        // Orientation: 1 -> Rotate CW
        if CustomView.selectedScreen == -1 {
        }
        else {
            RotateScreen.personalRotateToSpecificOrientation(targetDisplayUnit: CustomView.selectedScreen, Orientation: 1)
        }
    }
    
    @IBAction func rotateScreenCounterclockwiseClicked(_ sender: Any) {
        // Orientation: 1 -> Rotate CCW
        if CustomView.selectedScreen == -1 {
        }
        else {
            RotateScreen.personalRotateToSpecificOrientation(targetDisplayUnit: CustomView.selectedScreen, Orientation: 2)
        }
    }
    
    @IBAction func openAtLoginClicked(_ sender: Any) {
        if openAtLoginMenuItem.state == .on {
            openAtLoginMenuItem.state = .off
        }
        else {
            openAtLoginMenuItem.state = .on
        }
        
        SMLoginItemSetEnabled(helperBundleName as CFString, openAtLoginMenuItem.state == .on)
    }
    @IBAction func quitClicked(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
}

